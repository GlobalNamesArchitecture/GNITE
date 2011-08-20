# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-google_analytics}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason L Perry"]
  s.date = %q{2009-10-14}
  s.description = %q{Embeds GA tracking code in the bottom of HTML documents}
  s.email = %q{jasper@ambethia.com}
  s.files = ["test/rack/google_analytics_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/ambethia/rack-google_analytics}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Google Analytics for Rack applications}
  s.test_files = ["test/rack/google_analytics_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
