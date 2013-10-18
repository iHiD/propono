require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

namespace :test do
  Rake::TestTask.new(:travis) do |t|
    t.pattern = "test/{components,services}/*_test.rb"
  end
end

task default: :test
