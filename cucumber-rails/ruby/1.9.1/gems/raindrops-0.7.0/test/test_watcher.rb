# -*- encoding: binary -*-
require "test/unit"
require "rack"
require "raindrops"

class TestWatcher < Test::Unit::TestCase
  TEST_ADDR = ENV['UNICORN_TEST_ADDR'] || '127.0.0.1'
  def check_headers(headers)
    %w(X-Count X-Std-Dev X-Min X-Max X-Mean
       X-Outliers-Low X-Outliers-Low X-Last-Reset).each { |x|
      assert_kind_of String, headers[x], "#{x} missing"
    }
  end

  def teardown
    @app.shutdown
    @ios.each { |io| io.close unless io.closed? }
  end

  def setup
    @ios = []
    @srv = TCPServer.new TEST_ADDR, 0
    @ios << @srv
    @port = @srv.addr[1]
    @client = TCPSocket.new TEST_ADDR, @port
    @addr = "#{TEST_ADDR}:#{@port}"
    @ios << @client
    @app = Raindrops::Watcher.new :delay => 0.001
    @req = Rack::MockRequest.new @app
  end

  def test_index
    resp = @req.get "/"
    assert_equal 200, resp.status.to_i
    t = Time.parse resp.headers["Last-Modified"]
    assert_in_delta Time.now.to_f, t.to_f, 2.0
  end

  def test_active_txt
    resp = @req.get "/active/#@addr.txt"
    assert_equal 200, resp.status.to_i
    assert_equal "text/plain", resp.headers["Content-Type"]
    check_headers(resp.headers)
  end

  def test_active_html
    resp = @req.get "/active/#@addr.html"
    assert_equal 200, resp.status.to_i
    assert_equal "text/html", resp.headers["Content-Type"]
    check_headers(resp.headers)
  end

  def test_queued_txt
    resp = @req.get "/queued/#@addr.txt"
    assert_equal 200, resp.status.to_i
    assert_equal "text/plain", resp.headers["Content-Type"]
    check_headers(resp.headers)
  end

  def test_queued_html
    resp = @req.get "/queued/#@addr.html"
    assert_equal 200, resp.status.to_i
    assert_equal "text/html", resp.headers["Content-Type"]
    check_headers(resp.headers)
  end

  def test_reset
    resp = @req.post "/reset/#@addr"
    assert_equal 302, resp.status.to_i
  end

  def test_tail
    env = @req.class.env_for "/tail/#@addr.txt"
    status, headers, body = @app.call env
    assert_equal "text/plain", headers["Content-Type"]
    assert_equal 200, status.to_i
    tmp = []
    body.each do |x|
      assert_kind_of String, x
      tmp << x
      break if tmp.size > 1
    end
  end

  def test_tail_queued_min
    env = @req.class.env_for "/tail/#@addr.txt?queued_min=1"
    status, headers, body = @app.call env
    assert_equal "text/plain", headers["Content-Type"]
    assert_equal 200, status.to_i
    tmp = []
    body.each do |x|
      tmp = TCPSocket.new TEST_ADDR, @port
      @ios << tmp
      assert_kind_of String, x
      assert_equal 1, x.strip.split(/\s+/).last.to_i
      break
    end
  end
end if RUBY_PLATFORM =~ /linux/
