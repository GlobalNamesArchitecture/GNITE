# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{parsley-store}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitry Mozzherin"]
  s.date = %q{2010-11-06}
  s.default_executable = %q{parsley-store}
  s.description = %q{Scientific names parser/atomizer with cached distributed storage of atomized data}
  s.email = %q{dmozzherin@gmail.com}
  s.executables = ["parsley-store"]
  s.files = ["spec/parsley-store_spec.rb", "spec/spec_helper.rb", "bin/parsley-store"]
  s.homepage = %q{http://github.com/GlobalNamesArchitecture/parsley-store}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Scientific Names Parser with Cached Results}
  s.test_files = ["spec/parsley-store_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_runtime_dependency(%q<biodiversity>, [">= 0"])
      s.add_runtime_dependency(%q<redis>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<biodiversity>, [">= 0"])
      s.add_dependency(%q<redis>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<biodiversity>, [">= 0"])
    s.add_dependency(%q<redis>, [">= 0"])
  end
end
