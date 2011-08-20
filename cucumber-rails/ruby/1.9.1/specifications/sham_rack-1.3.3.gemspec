# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sham_rack}
  s.version = "1.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Williams"]
  s.date = %q{2010-12-21}
  s.description = %q{ShamRack plumbs Net::HTTP directly into Rack, for quick and easy HTTP testing.}
  s.email = %q{mdub@dogbiscuit.org}
  s.files = ["spec/sham_rack/stub_web_service_spec.rb", "spec/sham_rack_spec.rb", "spec/spec_helper.rb", "spec/test_apps.rb", "Rakefile", "benchmark/benchmark.rb", "benchmark/hello_app.rb"]
  s.homepage = %q{http://github.com/mdub/sham_rack}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{shamrack}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Net::HTTP-to-Rack plumbing}
  s.test_files = ["spec/sham_rack/stub_web_service_spec.rb", "spec/sham_rack_spec.rb", "spec/spec_helper.rb", "spec/test_apps.rb", "Rakefile", "benchmark/benchmark.rb", "benchmark/hello_app.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
  end
end
