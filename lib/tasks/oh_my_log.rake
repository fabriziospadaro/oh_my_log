# frozen_string_literal: true
require 'rake'

namespace :oh_my_log do
  desc 'Generate the observers for each ActiveRecord model'
  # in futuro fare che puoi passare parametri e in base a quello limita gli observer da generare
  task generate_observers: :environment do
    raise "Cannot create observers without an initializer, did you created it with 'oh_my_log:generate_initializer'" unless File.file?(Rails.root + 'config/initializers/oh_my_log_initializer.rb')
    OhMyLog::ObserverFactory.generate_collection
  end
  desc 'Generate a template initializer for OhMyLog'
  # in futuro puoi passare direttamente qui alcune impostazioni dell' initialize
  task generate_initializer: :environment do
    raise 'The initializer has been already generated!' if File.file?(Rails.root + 'config/initializers/oh_my_log_initializer')
    OhMyLog.generate_initializer
  end

  desc 'Install the gem by building initializer and observers'
  task install: :environment do
    Rake::Task['oh_my_log:generate_initializer'].invoke
    p "generated initializer"
    sleep(1)
    require Rails.root + "config/initializers/oh_my_log_initializer.rb"
    Rake::Task['oh_my_log:generate_observers'].invoke
    p "generated collections"
  end

  desc 'Clean observers and initializer'
  task clean: :environment do
    OhMyLog.destroy_initializer
    OhMyLog::ObserverFactory.remove_collection
  end
end