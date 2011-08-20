# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{uuid}
  s.version = "2.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Assaf Arkin", "Eric Hodel"]
  s.date = %q{2011-08-01}
  s.default_executable = %q{uuid}
  s.description = %q{UUID generator for producing universally unique identifiers based on RFC 4122
(http://www.ietf.org/rfc/rfc4122.txt).
}
  s.email = %q{assaf@labnotes.org}
  s.executables = ["uuid"]
  s.files = ["bin/uuid"]
  s.homepage = %q{http://github.com/assaf/uuid}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{UUID generator}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<macaddr>, ["~> 1.0"])
    else
      s.add_dependency(%q<macaddr>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<macaddr>, ["~> 1.0"])
  end
end
