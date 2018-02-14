# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'yard'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new do |task|
  task.options << '-D'
end

YARD::Rake::YardocTask.new do |task|
  task.files         = ['lib/**/*.rb']
  task.stats_options = ['--list-undoc']
end

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -I lib -r esi.rb'
end

task default: %i(yard rubocop test)
