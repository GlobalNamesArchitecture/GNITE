# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rspec-rails}
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chelimsky", "Chad Humphries"]
  s.date = %q{2010-10-15}
  s.description = %q{RSpec-2 for Rails-3}
  s.email = %q{dchelimsky@gmail.com;chad.humphries@gmail.com}
  s.files = ["features/README.markdown", "features/controller_specs/anonymous_controller.feature", "features/controller_specs/isolation_from_views.feature", "features/controller_specs/readers.feature", "features/controller_specs/render_views.feature", "features/helper_specs/helper_spec.feature", "features/mailer_specs/url_helpers.feature", "features/matchers/be_routable_matcher.feature", "features/matchers/new_record_matcher.feature", "features/matchers/redirect_to_matcher.feature", "features/matchers/render_template_matcher.feature", "features/mocks/mock_model.feature", "features/mocks/stub_model.feature", "features/model_specs/errors_on.feature", "features/model_specs/transactional_examples.feature", "features/routing_specs/access_to_named_routes.feature", "features/step_definitions/model_steps.rb", "features/support/env.rb", "features/view_specs/inferred_controller_path.feature", "features/view_specs/view_spec.feature", "spec/autotest/rails_rspec2_spec.rb", "spec/rspec/rails/assertion_adapter_spec.rb", "spec/rspec/rails/example/controller_example_group_spec.rb", "spec/rspec/rails/example/helper_example_group_spec.rb", "spec/rspec/rails/example/mailer_example_group_spec.rb", "spec/rspec/rails/example/model_example_group_spec.rb", "spec/rspec/rails/example/request_example_group_spec.rb", "spec/rspec/rails/example/routing_example_group_spec.rb", "spec/rspec/rails/example/view_example_group_spec.rb", "spec/rspec/rails/example/view_rendering_spec.rb", "spec/rspec/rails/fixture_support_spec.rb", "spec/rspec/rails/matchers/be_a_new_spec.rb", "spec/rspec/rails/matchers/be_new_record_spec.rb", "spec/rspec/rails/matchers/errors_on_spec.rb", "spec/rspec/rails/matchers/redirect_to_spec.rb", "spec/rspec/rails/matchers/render_template_spec.rb", "spec/rspec/rails/matchers/route_to_spec.rb", "spec/rspec/rails/mocks/ar_classes.rb", "spec/rspec/rails/mocks/mock_model_spec.rb", "spec/rspec/rails/mocks/stub_model_spec.rb", "spec/spec_helper.rb", "spec/support/helpers.rb"]
  s.homepage = %q{http://github.com/rspec/rspec-rails}
  s.post_install_message = %q{**************************************************

  Thank you for installing rspec-rails-2.0.1!

  This version of rspec-rails only works with versions of rails >= 3.0.0

  To configure your app to use rspec-rails, add a declaration to your Gemfile.
  If you are using Bundler's grouping feature in your Gemfile, be sure to include
  rspec-rails in the :development group as well as the :test group so that you
  can access its generators and rake tasks.

    group :development, :test do
      gem "rspec-rails", ">= 2.0.1"
    end

  Be sure to run the following command in each of your Rails apps if you're
  upgrading:

    script/rails generate rspec:install

  Even if you've run it before, this ensures that you have the latest updates
  to spec/spec_helper.rb and any other support files.

  Beta versions of rspec-rails-2 installed files that are no longer being used,
  so please remove these files if you have them:

    lib/tasks/rspec.rake
    config/initializers/rspec_generator.rb

  Lastly, be sure to look at Upgrade.markdown to see what might have changed
  since the last release.

**************************************************
}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rspec}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{rspec-rails-2.0.1}
  s.test_files = ["features/README.markdown", "features/controller_specs/anonymous_controller.feature", "features/controller_specs/isolation_from_views.feature", "features/controller_specs/readers.feature", "features/controller_specs/render_views.feature", "features/helper_specs/helper_spec.feature", "features/mailer_specs/url_helpers.feature", "features/matchers/be_routable_matcher.feature", "features/matchers/new_record_matcher.feature", "features/matchers/redirect_to_matcher.feature", "features/matchers/render_template_matcher.feature", "features/mocks/mock_model.feature", "features/mocks/stub_model.feature", "features/model_specs/errors_on.feature", "features/model_specs/transactional_examples.feature", "features/routing_specs/access_to_named_routes.feature", "features/step_definitions/model_steps.rb", "features/support/env.rb", "features/view_specs/inferred_controller_path.feature", "features/view_specs/view_spec.feature", "spec/autotest/rails_rspec2_spec.rb", "spec/rspec/rails/assertion_adapter_spec.rb", "spec/rspec/rails/example/controller_example_group_spec.rb", "spec/rspec/rails/example/helper_example_group_spec.rb", "spec/rspec/rails/example/mailer_example_group_spec.rb", "spec/rspec/rails/example/model_example_group_spec.rb", "spec/rspec/rails/example/request_example_group_spec.rb", "spec/rspec/rails/example/routing_example_group_spec.rb", "spec/rspec/rails/example/view_example_group_spec.rb", "spec/rspec/rails/example/view_rendering_spec.rb", "spec/rspec/rails/fixture_support_spec.rb", "spec/rspec/rails/matchers/be_a_new_spec.rb", "spec/rspec/rails/matchers/be_new_record_spec.rb", "spec/rspec/rails/matchers/errors_on_spec.rb", "spec/rspec/rails/matchers/redirect_to_spec.rb", "spec/rspec/rails/matchers/render_template_spec.rb", "spec/rspec/rails/matchers/route_to_spec.rb", "spec/rspec/rails/mocks/ar_classes.rb", "spec/rspec/rails/mocks/mock_model_spec.rb", "spec/rspec/rails/mocks/stub_model_spec.rb", "spec/spec_helper.rb", "spec/support/helpers.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, ["~> 2.0.0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.0.0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.0.0"])
  end
end
