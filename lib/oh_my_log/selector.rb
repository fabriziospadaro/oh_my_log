module OhMyLog
  module Log
    #Selector is a set of rule that Log.loggable? will have to respect
    class Selector
      attr_reader :controllers, :actions, :status_codes, :ips, :methods
      METHODS = ["GET", "HEAD", "POST", "PATCH", "PUT", "DELETE"].freeze
      ACTIONS = ["ONLY", "EXCEPT", "ALL"].freeze
      # TODO: add methods in the same style as anything else
      # and it will affect the parameter method in the loggable function in LOG.rb
      # EXCEPT O ONLY
      def initialize(controllers: default_hash_setting, actions: default_hash_setting, ips: default_hash_setting, status_codes: default_hash_setting, methods: default_hash_setting)
        @controllers = controllers
        @actions = actions
        @ips = ips
        @status_codes = status_codes
        @methods = methods
        build_attr_setters
      end

      private

      def default_hash_setting
        return {"ALL" => []}
      end

      def self.default_hash_setting
        return {"ALL" => []}
      end

      def build_attr_setters
        self.instance_variables.each do |attribute|
          attribute = attribute.to_s.gsub("@", "")
          self.define_singleton_method(:"set_#{attribute}") do |value|
            raise "Unpermitted rule: use #{ACTIONS}" if attribute == "rule" && !ACTIONS.include?(value)
            instance_variable_set("@#{attribute}", value)
          end
        end
      end

      def self.universal_for(actions: default_hash_setting, controllers: default_hash_setting, methods: default_hash_setting)
        return Selector.new(controllers: controllers, actions: actions, methods: methods)
      end
    end
  end
end