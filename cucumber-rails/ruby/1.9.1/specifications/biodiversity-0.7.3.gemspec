# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{biodiversity}
  s.version = "0.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitry Mozzherin"]
  s.date = %q{2011-02-07}
  s.description = %q{Tools for biodiversity informatics}
  s.email = %q{dmozzherin@gmail.com}
  s.executables = ["nnparse", "parserver"]
  s.files = ["spec/biodiversity_spec.rb", "spec/guid/lsid.spec.rb", "spec/parser/scientific_name.spec.rb", "spec/parser/scientific_name_canonical.spec.rb", "spec/parser/scientific_name_clean.spec.rb", "spec/parser/scientific_name_dirty.spec.rb", "spec/parser/spec_helper.rb", "spec/spec_helper.rb", "bin/nnparse", "bin/parserver"]
  s.homepage = %q{http://github.com/GlobalNamesArchitecture/biodiversity}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Parser of scientific names}
  s.test_files = ["spec/biodiversity_spec.rb", "spec/guid/lsid.spec.rb", "spec/parser/scientific_name.spec.rb", "spec/parser/scientific_name_canonical.spec.rb", "spec/parser/scientific_name_clean.spec.rb", "spec/parser/scientific_name_dirty.spec.rb", "spec/parser/spec_helper.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<treetop>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<treetop>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<treetop>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
