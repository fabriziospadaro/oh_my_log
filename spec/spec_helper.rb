ENV['RAILS_ENV'] ||= 'test'
OHMYLOG_ORM = ENV.fetch('OHMYLOG_ORM', 'active_record').to_sym
require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_filter 'lib/railtie.rb'
  add_filter 'lib/tasks/oh_my_log.rake'
  add_filter 'lib/oh_my_log/orm'
  add_filter 'lib/oh_my_log/syslog_processors'
  add_filter 'spec'
  add_filter 'blue_print'
  add_group 'Tests', 'test'
end

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  Coveralls.wear!
end
require 'active_support/all'
require 'rails'
require 'dummy/config/environment'
require_relative "../spec/orm/#{OHMYLOG_ORM}"
# note that require 'rspec-rails' does not work
# https://stackoverflow.com/questions/14458122/framework-integration-testing-within-a-gem-how-to-set-up-rspec-controller-test
require 'rspec/rails'
require 'oh_my_log'
require 'rake'

load File.expand_path("../../lib/tasks/oh_my_log.rake", __FILE__)
# make sure you set correct relative path
Rake::Task.define_task(:environment)