# frozen_string_literal: true

require 'rake/testtask'

# Tests
namespace :test do
  desc 'Test ForemanRescue'
  Rake::TestTask.new(:foreman_rescue) do |t|
    t.libs << "test"
    t.pattern = ["test/**/*_test.rb"]
    t.verbose = true
    t.warning = false
  end
end

Rake::Task[:test].enhance ['test:foreman_rescue']
