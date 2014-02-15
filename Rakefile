$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'bundler'
require 'rspec/core/rake_task'
require 'rake/clean'
require 'rubygems/tasks'

CLEAN.include("**/*.gem")

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
