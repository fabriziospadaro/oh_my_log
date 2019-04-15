require 'rails'
OHMYLOG_ORM rescue OHMYLOG_ORM = :active_record
Bundler.require :default, :orm
#creare una classe depency loader e usare il preload e l'after load
require_relative "oh_my_log/orm/#{OHMYLOG_ORM.to_s}"
#load the gem's lib folder
sources = ["oh_my_log/syslog_processors/", "oh_my_log/"]
sources.each do |base_path|
  Dir[File.dirname(__FILE__) + "/#{base_path}*.rb"].each do |file|
    name = File.basename(file, File.extname(file))
    next if (["mongoid_observer", "active_record_observer"]).include? name
    require_relative base_path + name
  end
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