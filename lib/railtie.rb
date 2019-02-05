#let's inject some code into rails before and after the initialization
class Railtie < ::Rails::Railtie
  #auto load our observers folder before rails freeze this variable
  initializer 'activeservice.autoload', :before => :set_autoload_paths do |app|
    if File.directory?(Rails.root + "app/models/observers/oh_my_log")
      app.config.autoload_paths << "app/models/observers/oh_my_log"
    else
      p "Could not find the observers folder, did you use the task to generate them?"
    end
  end

  #now let's start our gem(only if there is an initializer) after the rails initialize process
  config.after_initialize do
    #we are after the rails initialization time to load our file
    if defined?(Mongoid)
      require 'mongoid-observers'
      require_relative "oh_my_log/mongoid_observer"
    end
    unless File.file?(Rails.root + "config/initializers/oh_my_log_initializer.rb")
      #ok we create the initializer but we still need to execute it
      ::OhMyLog::generate_initializer
      #let's execute him now
      require Rails.root + "config/initializers/oh_my_log_initializer.rb"
      ::OhMyLog::ObserverFactory::generate_collection
    end
    ::OhMyLog::ObserverFactory.activate_observers
    ::OhMyLog.start

    class ::ApplicationController
      before_action :get__session__info

      def get__session__info
        user = nil
        if defined?(current_user)
          user = current_user
        elsif defined?(current_admin_user)
          user = current_admin_user
        end
        Thread.current[:user] = user
        Thread.current[:remote_ip] = request.remote_ip
      end
    end
  end

  #time to add some tasks
  rake_tasks do
    load 'tasks/oh_my_log.rake'
  end
end