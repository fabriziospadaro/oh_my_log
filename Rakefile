# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'rdoc/task'
require 'oh_my_log/version'

desc 'Default: generate Oh My Log doc'
task default: :doc

Rake::RDocTask.new(:doc) do |rdoc|
  version = OhMyLog::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "oh_my_log_#{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end