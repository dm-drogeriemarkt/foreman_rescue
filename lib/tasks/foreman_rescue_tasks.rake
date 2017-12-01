require 'rake/testtask'

# Tests
namespace :test do
  desc 'Test ForemanRescue'
  Rake::TestTask.new(:foreman_rescue) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_rescue do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_rescue) do |task|
        task.patterns = ["#{ForemanRescue::Engine.root}/app/**/*.rb",
                         "#{ForemanRescue::Engine.root}/lib/**/*.rb",
                         "#{ForemanRescue::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_rescue'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_rescue']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:foreman_rescue', 'foreman_rescue:rubocop']
end
