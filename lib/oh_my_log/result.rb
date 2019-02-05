# Result contains the request and all the effects that a specific request caused all over the models
module OhMyLog
  module Log
    class Result
      attr_reader :effects
      attr_reader :request

      def initialize(request)
        @request = request
        @effects = calculate_effects
      end

      # call this to record the current action done by the user
      def record!
        if OhMyLog::Log.configuration.print_log
          p "REQUEST"
          p @request.to_s
          p "RESPONSE" unless @effects.empty?
          @effects.each {|effect| p effect.to_s}
        end

        print_into_log

        #we can record everything that happend (OPTIONALL)
        if OhMyLog::Log.configuration.record_history
          OhMyLog::Log.history << self
        end
        #We always save the last operation recorded
        OhMyLog::Log.last_recorded = self
        #save this string on file or upload it somewhere
      end

      private

      def print_into_log
        OhMyLog::Log.configuration.log_instance.info('REQUEST')
        OhMyLog::Log.configuration.log_instance.info(@request.to_s)
        OhMyLog::Log.configuration.log_instance.info('RESPONSE') unless @effects.empty?
        @effects.each {|effect| OhMyLog::Log.configuration.log_instance.info(effect.to_s)}
      end

      def calculate_effects
        return OhMyLog::Log::targets.map {|target| Effect.new(target)}
      end

    end
  end
end