ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_group 'Tests', 'test'
end

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  Coveralls.wear!
end
require 'active_support/all'
require 'dummy/config/environment'
# note that require 'rspec-rails' does not work
# https://stackoverflow.com/questions/14458122/framework-integration-testing-within-a-gem-how-to-set-up-rspec-controller-test
require 'rspec/rails'
require 'oh_my_log'
require 'rake'

load File.expand_path("../../lib/tasks/oh_my_log.rake", __FILE__)
# make sure you set correct relative path
Rake::Task.define_task(:environment)

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

if Rails.gem_version >= Gem::Version.new('5.2.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __FILE__)).migrate
else
  ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate', __FILE__))
end
