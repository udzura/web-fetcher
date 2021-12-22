# frozen_string_literal: true
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

require "bundler/gem_tasks"
task default: %i[]

task :build => ["Dockerfile"] do
  sh 'docker build -t web-fetcher .'
end
