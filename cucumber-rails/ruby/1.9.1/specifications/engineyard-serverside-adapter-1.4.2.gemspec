# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{engineyard-serverside-adapter}
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Emde", "Sam Merritt"]
  s.date = %q{2011-08-03}
  s.description = %q{A separate adapter for speaking the CLI language of the engineyard-serverside gem.}
  s.email = ["memde@engineyard.com", "smerritt@engineyard.com>"]
  s.homepage = %q{http://github.com/engineyard/engineyard-serverside-adapter}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{engineyard-serverside-adapter}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Adapter for speaking to engineyard-serverside}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<escape>, ["~> 0.0.4"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<escape>, ["~> 0.0.4"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<escape>, ["~> 0.0.4"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<rspec>, ["~> 1.3.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
