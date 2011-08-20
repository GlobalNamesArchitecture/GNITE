# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dwc-archive}
  s.version = "0.5.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitry Mozzherin"]
  s.date = %q{2011-05-26}
  s.description = %q{Darwin Core Archive is the current standard exchange format for GLobal Names Architecture modules. This gem makes it easy to incorporate files in Darwin Core Archive format into a ruby project.}
  s.email = %q{dmozzherin at gmail dot com}
  s.homepage = %q{http://github.com/GlobalNamesArchitecture/dwc-archive}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Handler of Darwin Core Archive files}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parsley-store>, [">= 0.2.0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<parsley-store>, [">= 0.2.0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<parsley-store>, [">= 0.2.0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end
