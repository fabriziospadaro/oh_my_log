ENV['RAILS_ENV'] ||= 'test'
require 'active_support/all'
require 'dummy/config/environment'
# note that require 'rspec-rails' does not work
# https://stackoverflow.com/questions/14458122/framework-integration-testing-within-a-gem-how-to-set-up-rspec-controller-test
require 'rspec/rails'
require 'oh_my_log'

require 'coveralls'
Coveralls.wear!

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

if Rails.gem_version >= Gem::Version.new('5.2.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __FILE__)).migrate
else
  ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate', __FILE__))
end
