require 'rails/observers/activerecord/base'
#force LOAD the gem "rails-observers"
module ActiveRecord
  autoload :Observer, 'rails/observers/activerecord/observer'
end

#load the gem's lib folder
Dir[File.dirname(__FILE__) + '/oh_my_log/*.rb'].each do |file|
  name = File.basename(file, File.extname(file))
  #we are gonna skip this file FOR NOW since it depends of gem loaded after the rails initializer
  next if name == "mongoid_observer"
  require_relative "oh_my_log/" + name
end

module OhMyLog
  #call this after you configured the Log Module
  def self.start
    activate
    #the main loop to get callbacks from controllers
    ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
      data = args[-1]
      if Log::loggable?(data[:params], data[:status], data[:method])
        request = Log::Request.new(sender: Thread.current[:user], date: Time.now.utc, params: data[:params], method: data[:method], status: data[:status], path: data[:path])
        result = Log::Result.new(request)
        result.record!
      end
      Log::flush
    end
  end

  def self.activate
    if defined?(Mongoid)
      require 'mongoid-observers'
      require_relative "oh_my_log/mongoid_observer"
    end
    begin
      require Rails.root + "config/initializers/oh_my_log_initializer.rb"
      ::OhMyLog::ObserverFactory.activate_observers
    rescue
      return "could not start the gem, did you run oh_my_log:install ?"
    end
  end

  def self.generate_initializer
    FileUtils.cp_r(File.expand_path(__dir__ + '/../blue_print/oh_my_log_initializer.rb'), Rails.root + "config/initializers")
    p "Successfully created initializer!"
  end

  def self.destroy_initializer
    path = Rails.root + "config/initializers/oh_my_log_initializer.rb"
    File.delete(path) if File.exist?(path)
    p "Successfully destroyed the initializer!"
  end

end

#load the script to inject code to rails source and create rake task
require_relative "railtie"

