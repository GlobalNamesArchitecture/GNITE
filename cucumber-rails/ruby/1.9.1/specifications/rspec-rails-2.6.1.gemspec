# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rspec-rails}
  s.version = "2.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chelimsky"]
  s.date = %q{2011-05-25}
  s.description = %q{RSpec-2 for Rails-3}
  s.email = %q{dchelimsky@gmail.com}
  s.files = ["features/Autotest.md", "features/Changelog.md", "features/Generators.md", "features/GettingStarted.md", "features/README.md", "features/RailsVersions.md", "features/Upgrade.md", "features/controller_specs/README.md", "features/controller_specs/anonymous_controller.feature", "features/controller_specs/controller_spec.feature", "features/controller_specs/isolation_from_views.feature", "features/controller_specs/render_views.feature", "features/helper_specs/helper_spec.feature", "features/mailer_specs/url_helpers.feature", "features/matchers/README.md", "features/matchers/new_record_matcher.feature", "features/matchers/redirect_to_matcher.feature", "features/matchers/render_template_matcher.feature", "features/mocks/mock_model.feature", "features/mocks/stub_model.feature", "features/model_specs/README.md", "features/model_specs/errors_on.feature", "features/model_specs/transactional_examples.feature", "features/request_specs/request_spec.feature", "features/routing_specs/README.md", "features/routing_specs/be_routable_matcher.feature", "features/routing_specs/named_routes.feature", "features/routing_specs/route_to_matcher.feature", "features/step_definitions/additional_cli_steps.rb", "features/step_definitions/model_steps.rb", "features/support/env.rb", "features/view_specs/inferred_controller_path.feature", "features/view_specs/stub_template.feature", "features/view_specs/view_spec.feature", "spec/autotest/rails_rspec2_spec.rb", "spec/rspec/rails/assertion_adapter_spec.rb", "spec/rspec/rails/configuration_spec.rb", "spec/rspec/rails/deprecations_spec.rb", "spec/rspec/rails/example/controller_example_group_spec.rb", "spec/rspec/rails/example/helper_example_group_spec.rb", "spec/rspec/rails/example/mailer_example_group_spec.rb", "spec/rspec/rails/example/model_example_group_spec.rb", "spec/rspec/rails/example/request_example_group_spec.rb", "spec/rspec/rails/example/routing_example_group_spec.rb", "spec/rspec/rails/example/view_example_group_spec.rb", "spec/rspec/rails/extensions/active_model/errors_on_spec.rb", "spec/rspec/rails/extensions/active_record/records_spec.rb", "spec/rspec/rails/fixture_support_spec.rb", "spec/rspec/rails/matchers/be_a_new_spec.rb", "spec/rspec/rails/matchers/be_new_record_spec.rb", "spec/rspec/rails/matchers/be_routable_spec.rb", "spec/rspec/rails/matchers/errors_on_spec.rb", "spec/rspec/rails/matchers/redirect_to_spec.rb", "spec/rspec/rails/matchers/render_template_spec.rb", "spec/rspec/rails/matchers/route_to_spec.rb", "spec/rspec/rails/mocks/ar_classes.rb", "spec/rspec/rails/mocks/mock_model_spec.rb", "spec/rspec/rails/mocks/stub_model_spec.rb", "spec/rspec/rails/view_rendering_spec.rb", "spec/spec_helper.rb", "spec/support/helpers.rb", "spec/support/matchers.rb"]
  s.homepage = %q{http://github.com/rspec/rspec-rails}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rspec}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{rspec-rails-2.6.1}
  s.test_files = ["features/Autotest.md", "features/Changelog.md", "features/Generators.md", "features/GettingStarted.md", "features/README.md", "features/RailsVersions.md", "features/Upgrade.md", "features/controller_specs/README.md", "features/controller_specs/anonymous_controller.feature", "features/controller_specs/controller_spec.feature", "features/controller_specs/isolation_from_views.feature", "features/controller_specs/render_views.feature", "features/helper_specs/helper_spec.feature", "features/mailer_specs/url_helpers.feature", "features/matchers/README.md", "features/matchers/new_record_matcher.feature", "features/matchers/redirect_to_matcher.feature", "features/matchers/render_template_matcher.feature", "features/mocks/mock_model.feature", "features/mocks/stub_model.feature", "features/model_specs/README.md", "features/model_specs/errors_on.feature", "features/model_specs/transactional_examples.feature", "features/request_specs/request_spec.feature", "features/routing_specs/README.md", "features/routing_specs/be_routable_matcher.feature", "features/routing_specs/named_routes.feature", "features/routing_specs/route_to_matcher.feature", "features/step_definitions/additional_cli_steps.rb", "features/step_definitions/model_steps.rb", "features/support/env.rb", "features/view_specs/inferred_controller_path.feature", "features/view_specs/stub_template.feature", "features/view_specs/view_spec.feature", "spec/autotest/rails_rspec2_spec.rb", "spec/rspec/rails/assertion_adapter_spec.rb", "spec/rspec/rails/configuration_spec.rb", "spec/rspec/rails/deprecations_spec.rb", "spec/rspec/rails/example/controller_example_group_spec.rb", "spec/rspec/rails/example/helper_example_group_spec.rb", "spec/rspec/rails/example/mailer_example_group_spec.rb", "spec/rspec/rails/example/model_example_group_spec.rb", "spec/rspec/rails/example/request_example_group_spec.rb", "spec/rspec/rails/example/routing_example_group_spec.rb", "spec/rspec/rails/example/view_example_group_spec.rb", "spec/rspec/rails/extensions/active_model/errors_on_spec.rb", "spec/rspec/rails/extensions/active_record/records_spec.rb", "spec/rspec/rails/fixture_support_spec.rb", "spec/rspec/rails/matchers/be_a_new_spec.rb", "spec/rspec/rails/matchers/be_new_record_spec.rb", "spec/rspec/rails/matchers/be_routable_spec.rb", "spec/rspec/rails/matchers/errors_on_spec.rb", "spec/rspec/rails/matchers/redirect_to_spec.rb", "spec/rspec/rails/matchers/render_template_spec.rb", "spec/rspec/rails/matchers/route_to_spec.rb", "spec/rspec/rails/mocks/ar_classes.rb", "spec/rspec/rails/mocks/mock_model_spec.rb", "spec/rspec/rails/mocks/stub_model_spec.rb", "spec/rspec/rails/view_rendering_spec.rb", "spec/spec_helper.rb", "spec/support/helpers.rb", "spec/support/matchers.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])
      s.add_runtime_dependency(%q<railties>, ["~> 3.0"])
      s.add_runtime_dependency(%q<rspec>, ["~> 2.6.0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_dependency(%q<actionpack>, ["~> 3.0"])
      s.add_dependency(%q<railties>, ["~> 3.0"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0"])
    s.add_dependency(%q<actionpack>, ["~> 3.0"])
    s.add_dependency(%q<railties>, ["~> 3.0"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
  end
end
