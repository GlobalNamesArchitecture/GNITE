# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{formtastic}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin French"]
  s.date = %q{2010-09-07}
  s.description = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.email = %q{justin@indent.com.au}
  s.files = ["spec/buttons_spec.rb", "spec/commit_button_spec.rb", "spec/custom_builder_spec.rb", "spec/defaults_spec.rb", "spec/error_proc_spec.rb", "spec/errors_spec.rb", "spec/form_helper_spec.rb", "spec/helpers/layout_helper_spec.rb", "spec/i18n_spec.rb", "spec/include_blank_spec.rb", "spec/input_spec.rb", "spec/inputs/boolean_input_spec.rb", "spec/inputs/check_boxes_input_spec.rb", "spec/inputs/country_input_spec.rb", "spec/inputs/date_input_spec.rb", "spec/inputs/datetime_input_spec.rb", "spec/inputs/file_input_spec.rb", "spec/inputs/hidden_input_spec.rb", "spec/inputs/numeric_input_spec.rb", "spec/inputs/password_input_spec.rb", "spec/inputs/radio_input_spec.rb", "spec/inputs/select_input_spec.rb", "spec/inputs/string_input_spec.rb", "spec/inputs/text_input_spec.rb", "spec/inputs/time_input_spec.rb", "spec/inputs/time_zone_input_spec.rb", "spec/inputs_spec.rb", "spec/label_spec.rb", "spec/semantic_errors_spec.rb", "spec/semantic_fields_for_spec.rb", "spec/spec_helper.rb", "spec/support/custom_macros.rb", "spec/support/output_buffer.rb", "spec/support/test_environment.rb"]
  s.homepage = %q{http://github.com/justinfrench/formtastic/tree/master}
  s.post_install_message = %q{
  ========================================================================
  Thanks for installing Formtastic!
  ------------------------------------------------------------------------
  You can now (optionally) run the generator to copy some stylesheets and
  a config initializer into your application:
    rails generator formastic:install # Rails 3
    ./script/generate formtastic      # Rails 2

  To generate some semantic form markup for your existing models, just run:
    rails generate formtastic:form MODEL_NAME # Rails 3
    ./script/generate form MODEL_NAME         # Rails 2

  Find out more and get involved:
    http://github.com/justinfrench/formtastic
    http://groups.google.com.au/group/formtastic
  ========================================================================
  }
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.test_files = ["spec/buttons_spec.rb", "spec/commit_button_spec.rb", "spec/custom_builder_spec.rb", "spec/defaults_spec.rb", "spec/error_proc_spec.rb", "spec/errors_spec.rb", "spec/form_helper_spec.rb", "spec/helpers/layout_helper_spec.rb", "spec/i18n_spec.rb", "spec/include_blank_spec.rb", "spec/input_spec.rb", "spec/inputs/boolean_input_spec.rb", "spec/inputs/check_boxes_input_spec.rb", "spec/inputs/country_input_spec.rb", "spec/inputs/date_input_spec.rb", "spec/inputs/datetime_input_spec.rb", "spec/inputs/file_input_spec.rb", "spec/inputs/hidden_input_spec.rb", "spec/inputs/numeric_input_spec.rb", "spec/inputs/password_input_spec.rb", "spec/inputs/radio_input_spec.rb", "spec/inputs/select_input_spec.rb", "spec/inputs/string_input_spec.rb", "spec/inputs/text_input_spec.rb", "spec/inputs/time_input_spec.rb", "spec/inputs/time_zone_input_spec.rb", "spec/inputs_spec.rb", "spec/label_spec.rb", "spec/semantic_errors_spec.rb", "spec/semantic_fields_for_spec.rb", "spec/spec_helper.rb", "spec/support/custom_macros.rb", "spec/support/output_buffer.rb", "spec/support/test_environment.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<actionpack>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0.4.0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 1.2.6"])
      s.add_development_dependency(%q<rspec_tag_matchers>, [">= 1.0.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.0"])
      s.add_dependency(%q<actionpack>, [">= 2.3.0"])
      s.add_dependency(%q<i18n>, [">= 0.4.0"])
      s.add_dependency(%q<rspec-rails>, [">= 1.2.6"])
      s.add_dependency(%q<rspec_tag_matchers>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.0"])
    s.add_dependency(%q<actionpack>, [">= 2.3.0"])
    s.add_dependency(%q<i18n>, [">= 0.4.0"])
    s.add_dependency(%q<rspec-rails>, [">= 1.2.6"])
    s.add_dependency(%q<rspec_tag_matchers>, [">= 1.0.0"])
  end
end
