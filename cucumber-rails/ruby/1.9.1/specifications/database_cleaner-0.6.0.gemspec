# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{database_cleaner}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey"]
  s.date = %q{2010-10-25}
  s.description = %q{Strategies for cleaning databases.  Can be used to ensure a clean state for testing.}
  s.email = %q{ben@benmabey.com}
  s.files = ["spec/database_cleaner/active_record/base_spec.rb", "spec/database_cleaner/active_record/transaction_spec.rb", "spec/database_cleaner/active_record/truncation_spec.rb", "spec/database_cleaner/base_spec.rb", "spec/database_cleaner/configuration_spec.rb", "spec/database_cleaner/couch_potato/truncation_spec.rb", "spec/database_cleaner/data_mapper/base_spec.rb", "spec/database_cleaner/data_mapper/transaction_spec.rb", "spec/database_cleaner/data_mapper/truncation_spec.rb", "spec/database_cleaner/generic/base_spec.rb", "spec/database_cleaner/generic/truncation_spec.rb", "spec/database_cleaner/mongo_mapper/base_spec.rb", "spec/database_cleaner/mongo_mapper/mongo_examples.rb", "spec/database_cleaner/mongo_mapper/truncation_spec.rb", "spec/database_cleaner/mongoid/truncation_spec.rb", "spec/database_cleaner/shared_strategy_spec.rb", "spec/spec_helper.rb", "examples/features/step_definitions/activerecord_steps.rb", "examples/features/step_definitions/couchpotato_steps.rb", "examples/features/step_definitions/datamapper_steps.rb", "examples/features/step_definitions/mongoid_steps.rb", "examples/features/step_definitions/mongomapper_steps.rb", "examples/features/step_definitions/translation_steps.rb", "examples/features/support/env.rb", "examples/lib/activerecord_models.rb", "examples/lib/couchpotato_models.rb", "examples/lib/datamapper_models.rb", "examples/lib/mongoid_models.rb", "examples/lib/mongomapper_models.rb"]
  s.homepage = %q{http://github.com/bmabey/database_cleaner}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Strategies for cleaning databases.  Can be used to ensure a clean state for testing.}
  s.test_files = ["spec/database_cleaner/active_record/base_spec.rb", "spec/database_cleaner/active_record/transaction_spec.rb", "spec/database_cleaner/active_record/truncation_spec.rb", "spec/database_cleaner/base_spec.rb", "spec/database_cleaner/configuration_spec.rb", "spec/database_cleaner/couch_potato/truncation_spec.rb", "spec/database_cleaner/data_mapper/base_spec.rb", "spec/database_cleaner/data_mapper/transaction_spec.rb", "spec/database_cleaner/data_mapper/truncation_spec.rb", "spec/database_cleaner/generic/base_spec.rb", "spec/database_cleaner/generic/truncation_spec.rb", "spec/database_cleaner/mongo_mapper/base_spec.rb", "spec/database_cleaner/mongo_mapper/mongo_examples.rb", "spec/database_cleaner/mongo_mapper/truncation_spec.rb", "spec/database_cleaner/mongoid/truncation_spec.rb", "spec/database_cleaner/shared_strategy_spec.rb", "spec/spec_helper.rb", "examples/features/step_definitions/activerecord_steps.rb", "examples/features/step_definitions/couchpotato_steps.rb", "examples/features/step_definitions/datamapper_steps.rb", "examples/features/step_definitions/mongoid_steps.rb", "examples/features/step_definitions/mongomapper_steps.rb", "examples/features/step_definitions/translation_steps.rb", "examples/features/support/env.rb", "examples/lib/activerecord_models.rb", "examples/lib/couchpotato_models.rb", "examples/lib/datamapper_models.rb", "examples/lib/mongoid_models.rb", "examples/lib/mongomapper_models.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
