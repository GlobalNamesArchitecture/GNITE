# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = "0.7.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez", "Lloyd Hilaiel"]
  s.date = %q{2010-09-27}
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/extconf.rb"]
  s.files = ["spec/encoding/encoding_spec.rb", "spec/global/global_spec.rb", "spec/http/http_delete_spec.rb", "spec/http/http_error_spec.rb", "spec/http/http_get_spec.rb", "spec/http/http_post_spec.rb", "spec/http/http_put_spec.rb", "spec/json_gem_compatibility/compatibility_spec.rb", "spec/parsing/active_support_spec.rb", "spec/parsing/chunked_spec.rb", "spec/parsing/fixtures_spec.rb", "spec/parsing/one_off_spec.rb", "spec/spec_helper.rb", "examples/encoding/chunked_encoding.rb", "examples/encoding/one_shot.rb", "examples/encoding/to_an_io.rb", "examples/http/twitter_search_api.rb", "examples/http/twitter_stream_api.rb", "examples/parsing/from_file.rb", "examples/parsing/from_stdin.rb", "examples/parsing/from_string.rb", "ext/extconf.rb"]
  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{yajl-ruby}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Ruby C bindings to the excellent Yajl JSON stream-based parser library.}
  s.test_files = ["spec/encoding/encoding_spec.rb", "spec/global/global_spec.rb", "spec/http/http_delete_spec.rb", "spec/http/http_error_spec.rb", "spec/http/http_get_spec.rb", "spec/http/http_post_spec.rb", "spec/http/http_put_spec.rb", "spec/json_gem_compatibility/compatibility_spec.rb", "spec/parsing/active_support_spec.rb", "spec/parsing/chunked_spec.rb", "spec/parsing/fixtures_spec.rb", "spec/parsing/one_off_spec.rb", "spec/spec_helper.rb", "examples/encoding/chunked_encoding.rb", "examples/encoding/one_shot.rb", "examples/encoding/to_an_io.rb", "examples/http/twitter_search_api.rb", "examples/http/twitter_stream_api.rb", "examples/parsing/from_file.rb", "examples/parsing/from_stdin.rb", "examples/parsing/from_string.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
