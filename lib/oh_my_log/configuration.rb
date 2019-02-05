module OhMyLog
  module Log
    class Configuration
      attr_accessor :models, :print_log, :record_history, :log_instance, :log_path
      attr_reader :selectors

      def initialize(*args)
        @selectors = []
        #models not to track
        @models = {"ALL" => []}
        @print_log = true
        @log_instance = Logger.new(File.join(Rails.root, 'log/oh_my_log.log'))
        @log_path = nil
        #do we wanna keep track of all the actions?
        @record_history = false
      end

      def add_selector(selector)
        @selectors << selector
      end

      def reset_selectors
        @selectors = []
      end

      def get_actions(controller)
        @selectors.each do |selector|
          return selector.actions if selector.controller == controller
        end
      end

      def process_path
        @log_instance = Logger.new(@log_path) if (@log_path)
      end
    end
  end
end