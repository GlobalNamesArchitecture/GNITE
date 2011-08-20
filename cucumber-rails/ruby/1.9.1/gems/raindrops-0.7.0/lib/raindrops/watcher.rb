# -*- encoding: binary -*-
require "thread"
require "time"
require "socket"
require "rack"
require "aggregate"

# Raindrops::Watcher is a stand-alone Rack application for watching
# any number of TCP and UNIX listeners (all of them by default).
#
# It depends on the {Aggregate RubyGem}[http://rubygems.org/gems/aggregate]
#
# In your Rack config.ru:
#
#    run Raindrops::Watcher(options = {})
#
# It takes the following options hash:
#
# - :listeners - an array of listener names, (e.g. %w(0.0.0.0:80 /tmp/sock))
# - :delay - interval between stats updates in seconds (default: 1)
#
# Raindrops::Watcher is compatible any thread-safe/thread-aware Rack
# middleware.  It does not work well with multi-process web servers
# but can be used to monitor them.  It consumes minimal resources
# with the default :delay.
#
# == HTTP endpoints
#
# === GET /
#
# Returns an HTML summary listing of all listen interfaces watched on
#
# === GET /active/$LISTENER.txt
#
# Returns a plain text summary + histogram with X-* HTTP headers for
# active connections.
#
# e.g.: curl http://raindrops-demo.bogomips.org/active/0.0.0.0%3A80.txt
#
# === GET /active/$LISTENER.html
#
# Returns an HTML summary + histogram with X-* HTTP headers for
# active connections.
#
# e.g.: curl http://raindrops-demo.bogomips.org/active/0.0.0.0%3A80.html
#
# === GET /queued/$LISTENER.txt
#
# Returns a plain text summary + histogram with X-* HTTP headers for
# queued connections.
#
# e.g.: curl http://raindrops-demo.bogomips.org/queued/0.0.0.0%3A80.txt
#
# === GET /queued/$LISTENER.html
#
# Returns an HTML summary + histogram with X-* HTTP headers for
# queued connections.
#
# e.g.: curl http://raindrops-demo.bogomips.org/queued/0.0.0.0%3A80.html
#
# === GET /tail/$LISTENER.txt?active_min=1&queued_min=1
#
# Streams chunked a response to the client.
# Interval is the preconfigured +:delay+ of the application (default 1 second)
#
# The response is plain text in the following format:
#
#   ISO8601_TIMESTAMP LISTENER_NAME ACTIVE_COUNT QUEUED_COUNT LINEFEED
#
# Query parameters:
#
# - active_min - do not stream a line until this active count is reached
# - queued_min - do not stream a line until this queued count is reached
#
# == Response headers (mostly the same names as Raindrops::LastDataRecv)
#
# - X-Count   - number of samples polled
# - X-Last-Reset - date since the last reset
#
# The following headers are only present if X-Count is greater than one.
#
# - X-Min     - lowest number of connections recorded
# - X-Max     - highest number of connections recorded
# - X-Mean    - mean number of connections recorded
# - X-Std-Dev - standard deviation of connection count
# - X-Outliers-Low - number of low outliers (hopefully many for queued)
# - X-Outliers-High - number of high outliers (hopefully zero for queued)
#
# = Demo Server
#
# There is a server running this app at http://raindrops-demo.bogomips.org/
# The Raindrops::Middleware demo is also accessible at
# http://raindrops-demo.bogomips.org/_raindrops
#
# The demo server is only limited to 30 users, so be sure not to abuse it
# by using the /tail/ endpoint too much.
class Raindrops::Watcher
  # :stopdoc:
  attr_reader :snapshot
  include Rack::Utils
  include Raindrops::Linux
  DOC_URL = "http://raindrops.bogomips.org/Raindrops/Watcher.html"

  def initialize(opts = {})
    @tcp_listeners = @unix_listeners = nil
    if l = opts[:listeners]
      tcp, unix = [], []
      Array(l).each { |addr| (addr =~ %r{\A/} ? unix : tcp) << addr }
      unless tcp.empty? && unix.empty?
        @tcp_listeners = tcp
        @unix_listeners = unix
      end
    end

    agg_class = opts[:agg_class] || Aggregate
    start = Time.now.utc
    @active = Hash.new { |h,k| h[k] = agg_class.new }
    @queued = Hash.new { |h,k| h[k] = agg_class.new }
    @resets = Hash.new { |h,k| h[k] = start }
    @snapshot = [ start, {} ]
    @delay = opts[:delay] || 1
    @lock = Mutex.new
    @start = Mutex.new
    @cond = ConditionVariable.new
    @thr = nil
  end

  def hostname
    Socket.gethostname
  end

  # rack endpoint
  def call(env)
    @start.synchronize { @thr ||= aggregator_thread(env["rack.logger"]) }
    case env["REQUEST_METHOD"]
    when "HEAD", "GET"
      get env
    when "POST"
      post env
    else
      Rack::Response.new(["Method Not Allowed"], 405).finish
    end
  end

  def aggregator_thread(logger) # :nodoc:
    @socket = sock = Raindrops::InetDiagSocket.new
    thr = Thread.new do
      begin
        combined = tcp_listener_stats(@tcp_listeners, sock)
        combined.merge!(unix_listener_stats(@unix_listeners))
        @lock.synchronize do
          combined.each do |addr,stats|
            @active[addr] << stats.active
            @queued[addr] << stats.queued
          end
          @snapshot = [ Time.now.utc, combined ]
          @cond.broadcast
        end
      rescue => e
        logger.error "#{e.class} #{e.inspect}"
      end while sleep(@delay) && @socket
      sock.close
    end
    wait_snapshot
    thr
  end

  def active_stats(addr) # :nodoc:
    @lock.synchronize do
      tmp = @active[addr] or return
      [ @snapshot[0], @resets[addr], tmp.dup ]
    end
  end

  def queued_stats(addr) # :nodoc:
    @lock.synchronize do
      tmp = @queued[addr] or return
      [ @snapshot[0], @resets[addr], tmp.dup ]
    end
  end

  def wait_snapshot
    @lock.synchronize do
      @cond.wait @lock
      @snapshot
    end
  end

  def agg_to_hash(reset_at, agg)
    {
      "X-Count" => agg.count.to_s,
      "X-Min" => agg.min.to_s,
      "X-Max" => agg.max.to_s,
      "X-Mean" => agg.mean.to_s,
      "X-Std-Dev" => agg.std_dev.to_s,
      "X-Outliers-Low" => agg.outliers_low.to_s,
      "X-Outliers-High" => agg.outliers_high.to_s,
      "X-Last-Reset" => reset_at.httpdate,
    }
  end

  def histogram_txt(agg)
    updated_at, reset_at, agg = *agg
    headers = agg_to_hash(reset_at, agg)
    body = agg.to_s
    headers["Content-Type"] = "text/plain"
    headers["Expires"] = (updated_at + @delay).httpdate
    headers["Content-Length"] = bytesize(body).to_s
    [ 200, headers, [ body ] ]
  end

  def histogram_html(agg, addr)
    updated_at, reset_at, agg = *agg
    headers = agg_to_hash(reset_at, agg)
    body = "<html>" \
      "<head><title>#{hostname} - #{escape_html addr}</title></head>" \
      "<body><table>" <<
      headers.map { |k,v|
        "<tr><td>#{k.gsub(/^X-/, '')}</td><td>#{v}</td></tr>"
      }.join << "</table><pre>#{escape_html agg}</pre>" \
      "<form action='/reset/#{escape addr}' method='post'>" \
      "<input type='submit' name='x' value='reset' /></form>" \
      "</body>"
    headers["Content-Type"] = "text/html"
    headers["Expires"] = (updated_at + @delay).httpdate
    headers["Content-Length"] = bytesize(body).to_s
    [ 200, headers, [ body ] ]
  end

  def get(env)
    retried = false
    case env["PATH_INFO"]
    when "/"
      index
    when %r{\A/active/(.+)\.txt\z}
      histogram_txt(active_stats(unescape($1)))
    when %r{\A/active/(.+)\.html\z}
      addr = unescape $1
      histogram_html(active_stats(addr), addr)
    when %r{\A/queued/(.+)\.txt\z}
      histogram_txt(queued_stats(unescape($1)))
    when %r{\A/queued/(.+)\.html\z}
      addr = unescape $1
      histogram_html(queued_stats(addr), addr)
    when %r{\A/tail/(.+)\.txt\z}
      tail(unescape($1), env)
    else
      not_found
    end
    rescue Errno::EDOM
      raise if retried
      retried = true
      wait_snapshot
      retry
  end

  def not_found
    Rack::Response.new(["Not Found"], 404).finish
  end

  def post(env)
    case env["PATH_INFO"]
    when %r{\A/reset/(.+)\z}
      reset!(env, unescape($1))
    else
      not_found
    end
  end

  def reset!(env, addr)
    @lock.synchronize do
      @active.include?(addr) or return not_found
      @active.delete addr
      @queued.delete addr
      @resets[addr] = Time.now.utc
      @cond.wait @lock
    end
    req = Rack::Request.new(env)
    res = Rack::Response.new
    url = req.referer || "#{req.host_with_port}/"
    res.redirect(url)
    res.content_type.replace "text/plain"
    res.write "Redirecting to #{url}"
    res.finish
  end

  def index
    updated_at, all = snapshot
    headers = {
      "Content-Type" => "text/html",
      "Last-Modified" => updated_at.httpdate,
      "Expires" => (updated_at + @delay).httpdate,
    }
    body = "<html><head>" \
      "<title>#{hostname} - all interfaces</title>" \
      "</head><body><h3>Updated at #{updated_at.iso8601}</h3>" \
      "<table><tr>" \
        "<th>address</th><th>active</th><th>queued</th><th>reset</th>" \
      "</tr>" <<
      all.map do |addr,stats|
        e_addr = escape addr
        "<tr>" \
          "<td><a href='/tail/#{e_addr}.txt' " \
            "title='&quot;tail&quot; output in real time'" \
            ">#{escape_html addr}</a></td>" \
          "<td><a href='/active/#{e_addr}.html' " \
            "title='show active connection stats'>#{stats.active}</a></td>" \
          "<td><a href='/queued/#{e_addr}.html' " \
            "title='show queued connection stats'>#{stats.queued}</a></td>" \
          "<td><form action='/reset/#{e_addr}' method='post'>" \
            "<input title='reset statistics' " \
              "type='submit' name='x' value='x' /></form></td>" \
        "</tr>" \
      end.join << "</table>" \
      "<p>" \
        "This is running the #{self.class}</a> service, see " \
        "<a href='#{DOC_URL}'>#{DOC_URL}</a> " \
        "for more information and options." \
      "</p>" \
      "</body></html>"
    headers["Content-Length"] = bytesize(body).to_s
    [ 200, headers, [ body ] ]
  end

  def tail(addr, env)
    Tailer.new(self, addr, env).finish
  end

  # This is the response body returned for "/tail/$ADDRESS.txt".  This
  # must use a multi-threaded Rack server with streaming response support.
  # It is an internal class and not expected to be used directly
  class Tailer
    def initialize(rdmon, addr, env) # :nodoc:
      @rdmon = rdmon
      @addr = addr
      q = Rack::Utils.parse_query env["QUERY_STRING"]
      @active_min = q["active_min"].to_i
      @queued_min = q["queued_min"].to_i
      len = Rack::Utils.bytesize(addr)
      len = 35 if len > 35
      @fmt = "%20s % #{len}s % 10u % 10u\n"
      case env["HTTP_VERSION"]
      when "HTTP/1.0", nil
        @chunk = false
      else
        @chunk = true
      end
    end

    def finish
      headers = {
        "Content-Type" => "text/plain",
        "Cache-Control" => "no-transform",
        "Expires" => Time.at(0).httpdate,
      }
      headers["Transfer-Encoding"] = "chunked" if @chunk
      [ 200, headers, self ]
    end

    # called by the Rack server
    def each # :nodoc:
      begin
        time, all = @rdmon.wait_snapshot
        stats = all[@addr] or next
        stats.queued >= @queued_min or next
        stats.active >= @active_min or next
        body = sprintf(@fmt, time.iso8601, @addr, stats.active, stats.queued)
        body = "#{body.size.to_s(16)}\r\n#{body}\r\n" if @chunk
        yield body
      end while true
      yield "0\r\n\r\n" if @chunk
    end
  end

  # shuts down the background thread, only for tests
  def shutdown
    @socket = nil
    @thr.join if @thr
    @thr = nil
  end
  # :startdoc:
end
