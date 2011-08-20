# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bourne}
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joe Ferris"]
  s.date = %q{2010-06-08}
  s.description = %q{Extends mocha to allow detailed tracking and querying of
    stub and mock invocations. Allows test spies using the have_received rspec
    matcher and assert_received for Test::Unit. Extracted from the
    jferris-mocha fork.}
  s.email = %q{jferris@thoughtbot.com}
  s.homepage = %q{http://github.com/thoughtbot/bourne}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Adds test spies to mocha.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mocha>, ["= 0.9.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, ["= 0.9.8"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, ["= 0.9.8"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
