# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{escape_utils}
  s.version = "0.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = %q{2010-10-15}
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/extconf.rb"]
  s.files = ["spec/html/escape_spec.rb", "spec/html/unescape_spec.rb", "spec/html_safety_spec.rb", "spec/javascript/escape_spec.rb", "spec/javascript/unescape_spec.rb", "spec/query/escape_spec.rb", "spec/query/unescape_spec.rb", "spec/spec_helper.rb", "spec/uri/escape_spec.rb", "spec/uri/unescape_spec.rb", "spec/url/escape_spec.rb", "spec/url/unescape_spec.rb", "ext/extconf.rb"]
  s.homepage = %q{http://github.com/brianmario/escape_utils}
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Faster string escaping routines for your web apps}
  s.test_files = ["spec/html/escape_spec.rb", "spec/html/unescape_spec.rb", "spec/html_safety_spec.rb", "spec/javascript/escape_spec.rb", "spec/javascript/unescape_spec.rb", "spec/query/escape_spec.rb", "spec/query/unescape_spec.rb", "spec/spec_helper.rb", "spec/uri/escape_spec.rb", "spec/uri/unescape_spec.rb", "spec/url/escape_spec.rb", "spec/url/unescape_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
