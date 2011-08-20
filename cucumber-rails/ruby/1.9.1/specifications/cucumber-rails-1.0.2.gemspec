# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cucumber-rails}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aslak Hellesøy", "Dennis Blöte", "Rob Holland"]
  s.date = %q{2011-06-26}
  s.description = %q{Cucumber Generators and Runtime for Rails}
  s.email = %q{cukes@googlegroups.com}
  s.files = ["features/allow_rescue.feature", "features/capybara_javascript_drivers.feature", "features/database_cleaner.feature", "features/emulate_javascript.feature", "features/inspect_query_string.feature", "features/install_cucumber_rails.feature", "features/mongoid.feature", "features/multiple_databases.feature", "features/named_selectors.feature", "features/no_database.feature", "features/pseduo_class_selectors.feature", "features/rerun_profile.feature", "features/rest_api.feature", "features/routing.feature", "features/select_dates.feature", "features/step_definitions/cucumber_rails_steps.rb", "features/support/env.rb", "features/test_unit.feature", "spec/cucumber/web/tableish_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://cukes.info}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{cucumber-rails-1.0.2}
  s.test_files = ["features/allow_rescue.feature", "features/capybara_javascript_drivers.feature", "features/database_cleaner.feature", "features/emulate_javascript.feature", "features/inspect_query_string.feature", "features/install_cucumber_rails.feature", "features/mongoid.feature", "features/multiple_databases.feature", "features/named_selectors.feature", "features/no_database.feature", "features/pseduo_class_selectors.feature", "features/rerun_profile.feature", "features/rest_api.feature", "features/routing.feature", "features/select_dates.feature", "features/step_definitions/cucumber_rails_steps.rb", "features/support/env.rb", "features/test_unit.feature", "spec/cucumber/web/tableish_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cucumber>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<capybara>, [">= 1.0.0"])
      s.add_development_dependency(%q<rails>, [">= 3.1.0.rc4"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.15"])
      s.add_development_dependency(%q<aruba>, [">= 0.4.3"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.3"])
      s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 2.6.1"])
      s.add_development_dependency(%q<factory_girl>, [">= 2.0.0.beta2"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0.6.7"])
      s.add_development_dependency(%q<mongoid>, [">= 2.0.2"])
      s.add_development_dependency(%q<bson_ext>, [">= 1.3.1"])
      s.add_development_dependency(%q<turn>, [">= 0.8.2"])
      s.add_development_dependency(%q<sass>, [">= 3.1.3"])
      s.add_development_dependency(%q<coffee-script>, [">= 2.2.0"])
      s.add_development_dependency(%q<uglifier>, [">= 1.0.0"])
      s.add_development_dependency(%q<jquery-rails>, [">= 1.0.12"])
      s.add_development_dependency(%q<yard>, ["= 0.7.1"])
      s.add_development_dependency(%q<rdiscount>, ["= 1.6.8"])
      s.add_development_dependency(%q<bcat>, ["= 0.6.1"])
    else
      s.add_dependency(%q<cucumber>, ["~> 1.0.0"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.6"])
      s.add_dependency(%q<capybara>, [">= 1.0.0"])
      s.add_dependency(%q<rails>, [">= 3.1.0.rc4"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<bundler>, [">= 1.0.15"])
      s.add_dependency(%q<aruba>, [">= 0.4.3"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.3"])
      s.add_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_dependency(%q<rspec-rails>, [">= 2.6.1"])
      s.add_dependency(%q<factory_girl>, [">= 2.0.0.beta2"])
      s.add_dependency(%q<database_cleaner>, [">= 0.6.7"])
      s.add_dependency(%q<mongoid>, [">= 2.0.2"])
      s.add_dependency(%q<bson_ext>, [">= 1.3.1"])
      s.add_dependency(%q<turn>, [">= 0.8.2"])
      s.add_dependency(%q<sass>, [">= 3.1.3"])
      s.add_dependency(%q<coffee-script>, [">= 2.2.0"])
      s.add_dependency(%q<uglifier>, [">= 1.0.0"])
      s.add_dependency(%q<jquery-rails>, [">= 1.0.12"])
      s.add_dependency(%q<yard>, ["= 0.7.1"])
      s.add_dependency(%q<rdiscount>, ["= 1.6.8"])
      s.add_dependency(%q<bcat>, ["= 0.6.1"])
    end
  else
    s.add_dependency(%q<cucumber>, ["~> 1.0.0"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.6"])
    s.add_dependency(%q<capybara>, [">= 1.0.0"])
    s.add_dependency(%q<rails>, [">= 3.1.0.rc4"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<bundler>, [">= 1.0.15"])
    s.add_dependency(%q<aruba>, [">= 0.4.3"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.3"])
    s.add_dependency(%q<rspec>, [">= 2.6.0"])
    s.add_dependency(%q<rspec-rails>, [">= 2.6.1"])
    s.add_dependency(%q<factory_girl>, [">= 2.0.0.beta2"])
    s.add_dependency(%q<database_cleaner>, [">= 0.6.7"])
    s.add_dependency(%q<mongoid>, [">= 2.0.2"])
    s.add_dependency(%q<bson_ext>, [">= 1.3.1"])
    s.add_dependency(%q<turn>, [">= 0.8.2"])
    s.add_dependency(%q<sass>, [">= 3.1.3"])
    s.add_dependency(%q<coffee-script>, [">= 2.2.0"])
    s.add_dependency(%q<uglifier>, [">= 1.0.0"])
    s.add_dependency(%q<jquery-rails>, [">= 1.0.12"])
    s.add_dependency(%q<yard>, ["= 0.7.1"])
    s.add_dependency(%q<rdiscount>, ["= 1.6.8"])
    s.add_dependency(%q<bcat>, ["= 0.6.1"])
  end
end
