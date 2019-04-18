require File.expand_path('../boot', __FILE__)
require 'rails/all'
require 'oh_my_log'

if defined?(Bundler)
  Bundler.require(*Rails.groups(assets: %w[development test]))
  require "#{OHMYLOG_ORM}/railtie"
end

module RailsApp
  class Application < Rails::Application
    config.encoding = 'utf-8'

    config.filter_parameters += [:password]

    config.autoload_paths += ["#{config.root}/app/#{OHMYLOG_ORM}"]
    config.autoload_paths += ["#{config.root}/lib"]

    config.secret_key_base = 'fuuuuuuuuuuu'
  end
end
