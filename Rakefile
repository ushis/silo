#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)

Silo::Application.load_tasks

# We want a custom documentation.
RDoc::Task.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc/app'

  rdoc.options << '-f' << 'sdoc'
  rdoc.options << '-t' << 'Silo Documentation'
  rdoc.options << '-e' << 'UTF-8'
  rdoc.options << '-g'
  rdoc.options << '-m' << 'README'
  rdoc.options << '-a'

  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('app/**/*.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/tasks/*')
end
