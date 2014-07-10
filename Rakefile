require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'

Gnite::Application.load_tasks

task default: [:cucumber, :spec]

task "resque:setup" => :environment do
end

