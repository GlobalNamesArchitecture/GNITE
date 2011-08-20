# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{escape_utils}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = %q{2011-03-09}
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/escape_utils/extconf.rb"]
  s.files = ["spec/html/escape_spec.rb", "spec/html/unescape_spec.rb", "spec/html_safety_spec.rb", "spec/javascript/escape_spec.rb", "spec/javascript/unescape_spec.rb", "spec/query/escape_spec.rb", "spec/query/unescape_spec.rb", "spec/rcov.opts", "spec/spec_helper.rb", "spec/uri/escape_spec.rb", "spec/uri/unescape_spec.rb", "spec/url/escape_spec.rb", "spec/url/unescape_spec.rb", "ext/escape_utils/extconf.rb"]
  s.homepage = %q{http://github.com/brianmario/escape_utils}
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Faster string escaping routines for your web apps}
  s.test_files = ["spec/html/escape_spec.rb", "spec/html/unescape_spec.rb", "spec/html_safety_spec.rb", "spec/javascript/escape_spec.rb", "spec/javascript/unescape_spec.rb", "spec/query/escape_spec.rb", "spec/query/unescape_spec.rb", "spec/rcov.opts", "spec/spec_helper.rb", "spec/uri/escape_spec.rb", "spec/uri/unescape_spec.rb", "spec/url/escape_spec.rb", "spec/url/unescape_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake-compiler>, [">= 0.7.5"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_development_dependency(%q<rack>, [">= 0"])
      s.add_development_dependency(%q<haml>, [">= 0"])
      s.add_development_dependency(%q<fast_xs>, [">= 0"])
      s.add_development_dependency(%q<actionpack>, [">= 0"])
      s.add_development_dependency(%q<url_escape>, [">= 0"])
    else
      s.add_dependency(%q<rake-compiler>, [">= 0.7.5"])
      s.add_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<fast_xs>, [">= 0"])
      s.add_dependency(%q<actionpack>, [">= 0"])
      s.add_dependency(%q<url_escape>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake-compiler>, [">= 0.7.5"])
    s.add_dependency(%q<rspec>, [">= 2.0.0"])
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<fast_xs>, [">= 0"])
    s.add_dependency(%q<actionpack>, [">= 0"])
    s.add_dependency(%q<url_escape>, [">= 0"])
  end
end
