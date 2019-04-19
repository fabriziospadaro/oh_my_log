module OhMyLog
  class SyslogConfiguration
    @@processor_name = "RFC3164"
    @@split_operation = "split"

    def self.use(processor_name, operation = nil)
      raise "We don't support the #{processor_name} format" unless (("SyslogProcessors::#{processor_name.upcase}".constantize) rescue false)
      @@processor_name = processor_name
      on_message_too_long(operation) if operation
    end

    def self.processor_name
      return @@processor_name
    end

    def self.split_operation
      return @@split_operation
    end

    def self.on_message_too_long(operation)
      operation = operation.to_s.downcase.to_sym
      raise ArgumentError "Supported mode are: 'split' or 'trim'" unless [:split, :trim].include? operation
      @@split_operation = operation
    end
  end
end