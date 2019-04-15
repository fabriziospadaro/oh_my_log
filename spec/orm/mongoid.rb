# frozen_string_literal: true

require 'mongoid/version'
require 'mongoid'
Mongoid.configure do |config|
  config.load!('spec/support/mongoid.yml', Rails.env)
  config.use_utc = true
  config.include_root_in_json = true
end

ORMInvalidRecordException = Mongoid::Errors::Validations