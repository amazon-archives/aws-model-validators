require 'rspec/core/rake_task'

desc 'Runs unit tests'
RSpec::Core::RakeTask.new('test') do |task|
  task.rspec_opts = "--color --format d"
end

task 'default' => 'test'
