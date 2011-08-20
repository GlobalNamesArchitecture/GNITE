# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kgio}
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["kgio hackers"]
  s.date = %q{2010-10-07}
  s.description = %q{kgio provides non-blocking I/O methods for Ruby without raising
exceptions on EAGAIN and EINPROGRESS.  It is intended for use with the
Unicorn and Rainbows! Rack servers, but may be used by other
applications.}
  s.email = %q{mongrel-unicorn@rubyforge.org}
  s.extensions = ["ext/kgio/extconf.rb"]
  s.files = ["test/test_unix_connect.rb", "test/test_pipe_read_write.rb", "test/test_unix_server.rb", "test/test_socketpair_read_write.rb", "test/test_tcp_server.rb", "test/test_unix_server_read_client_write.rb", "test/test_tcp_connect.rb", "test/test_connect_fd_leak.rb", "test/test_tcp_server_read_client_write.rb", "test/test_unix_client_read_server_write.rb", "test/test_tcp_client_read_server_write.rb", "test/test_pipe_popen.rb", "test/test_accept_class.rb", "ext/kgio/extconf.rb"]
  s.homepage = %q{http://unicorn.bogomips.org/kgio/}
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{rainbows}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{kinder, gentler I/O for Ruby}
  s.test_files = ["test/test_unix_connect.rb", "test/test_pipe_read_write.rb", "test/test_unix_server.rb", "test/test_socketpair_read_write.rb", "test/test_tcp_server.rb", "test/test_unix_server_read_client_write.rb", "test/test_tcp_connect.rb", "test/test_connect_fd_leak.rb", "test/test_tcp_server_read_client_write.rb", "test/test_unix_client_read_server_write.rb", "test/test_tcp_client_read_server_write.rb", "test/test_pipe_popen.rb", "test/test_accept_class.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
