module OhMyLog
  module ObserverFactory

    #this will initialize the observes logic
    def self.activate_observers
      #should raise an error if there are no observers -> "Build the observer list using the task"
      Rails.application.eager_load!

      build_activerecord_obs if defined?(ActiveRecord)
      build_mongoid_obs if defined?(Mongoid)
    end

    #this will be runned by the task to build the collection of observed models FILE
    require 'fileutils'

    def self.generate_collection
      Rails.application.eager_load!

      #rebuild folder if it's already there
      FileUtils.rm_rf(Rails.root + "app/models/observers/oh_my_log") if File.directory?(Rails.root + "app/models/observers/oh_my_log")
      FileUtils.mkdir_p(Rails.root + "app/models/observers/oh_my_log")
      generate_collection_for(ActiveRecord) if defined?(ActiveRecord)
      generate_collection_for(Mongoid) if defined?(Mongoid)
    end

    private

    def self.build_activerecord_obs
      supported_models = supported_models_for(ActiveRecord)
      supported_models.each {|class_name| ActiveRecord::Base.add_observer class_name.instance}
    end

    def self.build_mongoid_obs
      supported_models = supported_models_for(Mongoid)
      supported_models.each {|class_name| ::Mongoid::Document.add_observer class_name.instance}
    end

    def self.generate_collection_for(klass)
      models = available_models_for(klass)
      models.each do |model|
        model_file = File.join("#{Rails.root}/app", "models", "observers", "oh_my_log", model.underscore + "_observer.rb")
        p "Generated #{model_file}"
        File.open(model_file, "w+") do |f|
          f << "class #{model + "Observer"} < OhMyLog::#{klass}Observer\nend"
        end
      end
    end

    def self.supported_models_for(klass)
      supported_models = []
      models = available_models_for(klass)
      models.each do |model|
        if File.file?(Rails.root + "app/models/observers/oh_my_log/#{model.underscore}_observer.rb")
          supported_models << ('::' + model + "Observer").constantize
        else
          p "You didn't create an observer for #{model.constantize}"
        end
      end
      return supported_models
    end

    private

    def self.available_models_for(klass)
      config_rule = Log.configuration_rule
      config_models = Log.configuration_models
      models = []
      if klass == ActiveRecord
        models = ActiveRecord::Base.subclasses.collect {|type| type.name}
        models = models + ApplicationRecord.subclasses.collect {|type| type.name} if defined?(ApplicationRecord)
      elsif klass == Mongoid
        models = Mongoid.models.collect {|type| type.name}
      end
      #reject modules
      models = models.reject {|model| model.include?("::") || model.include?("HABTM") || model.include?("Mongoid")}
      case config_rule
      when "ONLY"
        return models.select {|model| config_models.include?(model)}
      when "ALL"
        return models
      when "EXCEPT"
        return models.reject {|model| config_models.include?(model)}
      end
    end
  end
end