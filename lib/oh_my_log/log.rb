require "active_support/all"
require_relative '../oh_my_log'

module OhMyLog
  module Log
    #all the models effected by this
    mattr_accessor :targets
    #config for this log
    mattr_accessor :configuration
    #contains all the request done in a session
    mattr_accessor :history
    #last action done by the user
    mattr_accessor :last_recorded

    def self.configure
      self.configuration ||= Configuration.new
      self.targets = []
      self.history = []
      yield(configuration)
      self.configuration.add_selector(Selector.universal_for) if self.configuration.selectors.empty?
      self.configuration.process_path
    end

    def self.clear
      self.history = []
    end

    def self.reset
      self.clear
      self.flush
      self.configuration = nil
      self.last_recorded = nil
    end

    def self.add_target(target)
      #do not add duplicates
      self.targets << target unless self.targets.include? target
    end

    #Is the action/controller passed in params allowed by the selectors
    # TODO: add method as well in the selector
    def self.loggable?(params, status,method)
      ctrl_name = params["controller"]
      ctrl_action = params["action"].to_sym
      final_response = false
      self.configuration.selectors.each do |selector|
        #check if we are in status range
        in_range = true
        case selector.status_codes.keys[0]
        when "ONLY"
          in_range = false
          selector.status_codes.values[0].each do |range|
            range = (range.to_i..range.to_i) if range.class != Range
            in_range = (range === status.to_i) unless in_range
          end
        when "EXCEPT"
          selector.status_codes.values[0].each do |range|
            in_range = false if (range === status.to_i)
          end
        when "ALL"
          in_range = true
        else
          raise "UNDEFINED RULE: please us any of [ONLY/EXCEPT/ALL]"
        end
        final_response = in_range
        return false unless in_range

        permitted_controller = false
        case selector.controllers.keys[0]
        when "ALL"
          permitted_controller = true
        when "ONLY"
          permitted_controller = selector.controllers.values[0].include?(ctrl_name.classify)
        when "EXCEPT"
          permitted_controller = !selector.controllers.values[0].include?(ctrl_name.classify)
        else
          raise "UNDEFINED RULE: please us any of [ONLY/EXCEPT/ALL]"
        end
        final_response = final_response && permitted_controller
        return false unless permitted_controller

        permitted_ip = false
        case selector.ips.keys[0]
        when "EXCEPT"
          permitted_ip = selector.ips.values[0].include?(Thread.current[:remote_ip])
        when "ONLY"
          permitted_ip = !selector.ips.values[0].empty? && !selector.ips.values[0].include?(Thread.current[:remote_ip])
        when "ALL"
          permitted_ip = true
        else
          raise "UNDEFINED RULE: please us any of [ONLY/EXCEPT/ALL]"
        end
        final_response = final_response && permitted_ip
        return false unless permitted_ip
        #finisci questo
        case selector.actions.keys[0]
        when "EXCEPT"
          selector.actions.values[0].each {|action| final_response = false if action.downcase.to_sym == ctrl_action}
        when "ONLY"
          selector.actions.values[0].each {|action| final_response = true if action.downcase.to_sym == ctrl_action}
        when "ALL"
          final_response = true
        else
          raise "UNDEFINED RULE: please us any of [ONLY/EXCEPT/ALL]"
        end
        return false unless final_response
      end
      return final_response
    end

    #once we processed an action we can get rid of all the cached data(targets) stored in the Log
    def self.flush
      self.targets = []
    end
  end
end