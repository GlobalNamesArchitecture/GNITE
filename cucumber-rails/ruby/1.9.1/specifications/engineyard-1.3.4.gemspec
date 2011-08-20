# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{engineyard}
  s.version = "1.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["EY Cloud Team"]
  s.date = %q{2010-11-08}
  s.default_executable = %q{ey}
  s.description = %q{This gem allows you to deploy your rails application to the Engine Yard cloud directly from the command line.}
  s.email = %q{cloud@engineyard.com}
  s.executables = ["ey"]
  s.files = ["spec/engineyard/api_spec.rb", "spec/engineyard/cli/api_spec.rb", "spec/engineyard/cli_spec.rb", "spec/engineyard/collection/apps_spec.rb", "spec/engineyard/collection/environments_spec.rb", "spec/engineyard/config_spec.rb", "spec/engineyard/model/api_struct_spec.rb", "spec/engineyard/model/environment_spec.rb", "spec/engineyard/model/instance_spec.rb", "spec/engineyard/repo_spec.rb", "spec/engineyard/resolver_spec.rb", "spec/engineyard_spec.rb", "spec/ey/deploy_spec.rb", "spec/ey/ey_spec.rb", "spec/ey/list_environments_spec.rb", "spec/ey/logs_spec.rb", "spec/ey/rebuild_spec.rb", "spec/ey/recipes/apply_spec.rb", "spec/ey/recipes/download_spec.rb", "spec/ey/recipes/upload_spec.rb", "spec/ey/rollback_spec.rb", "spec/ey/ssh_spec.rb", "spec/ey/web/disable_spec.rb", "spec/ey/web/enable_spec.rb", "spec/spec_helper.rb", "spec/support/bundled_ey", "spec/support/fake_awsm.ru", "spec/support/git_repo.rb", "spec/support/helpers.rb", "spec/support/ruby_ext.rb", "spec/support/shared_behavior.rb", "bin/ey"]
  s.homepage = %q{http://github.com/engineyard/engineyard}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Command-line deployment for the Engine Yard cloud}
  s.test_files = ["spec/engineyard/api_spec.rb", "spec/engineyard/cli/api_spec.rb", "spec/engineyard/cli_spec.rb", "spec/engineyard/collection/apps_spec.rb", "spec/engineyard/collection/environments_spec.rb", "spec/engineyard/config_spec.rb", "spec/engineyard/model/api_struct_spec.rb", "spec/engineyard/model/environment_spec.rb", "spec/engineyard/model/instance_spec.rb", "spec/engineyard/repo_spec.rb", "spec/engineyard/resolver_spec.rb", "spec/engineyard_spec.rb", "spec/ey/deploy_spec.rb", "spec/ey/ey_spec.rb", "spec/ey/list_environments_spec.rb", "spec/ey/logs_spec.rb", "spec/ey/rebuild_spec.rb", "spec/ey/recipes/apply_spec.rb", "spec/ey/recipes/download_spec.rb", "spec/ey/recipes/upload_spec.rb", "spec/ey/rollback_spec.rb", "spec/ey/ssh_spec.rb", "spec/ey/web/disable_spec.rb", "spec/ey/web/enable_spec.rb", "spec/spec_helper.rb", "spec/support/bundled_ey", "spec/support/fake_awsm.ru", "spec/support/git_repo.rb", "spec/support/helpers.rb", "spec/support/ruby_ext.rb", "spec/support/shared_behavior.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, ["~> 0.14.3"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.4"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.6.1"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<escape>, ["~> 0.0.4"])
      s.add_runtime_dependency(%q<engineyard-serverside-adapter>, ["= 1.3.5"])
    else
      s.add_dependency(%q<thor>, ["~> 0.14.3"])
      s.add_dependency(%q<rest-client>, ["~> 1.4"])
      s.add_dependency(%q<highline>, ["~> 1.6.1"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<escape>, ["~> 0.0.4"])
      s.add_dependency(%q<engineyard-serverside-adapter>, ["= 1.3.5"])
    end
  else
    s.add_dependency(%q<thor>, ["~> 0.14.3"])
    s.add_dependency(%q<rest-client>, ["~> 1.4"])
    s.add_dependency(%q<highline>, ["~> 1.6.1"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<escape>, ["~> 0.0.4"])
    s.add_dependency(%q<engineyard-serverside-adapter>, ["= 1.3.5"])
  end
end
