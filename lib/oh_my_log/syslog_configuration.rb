module OhMyLog
  class SyslogConfiguration
    @@processor_name = "RFC3164"
    @@split_operation = "split"

    def self.use(processor_name = nil, operation = nil)
      change_processor(processor_name) if processor_name
      change_operation(operation) if operation
    end

    def self.processor_name
      return @@processor_name
    end

    def self.split_operation
      return @@split_operation
    end

    def self.change_processor(processor_name)
      raise "We don't support the #{processor_name} format" unless (("SyslogProcessors::#{processor_name.upcase}".constantize) rescue false)
      @@processor_name = processor_name
    end

    def self.change_operation(operation)
      operation = operation.to_s.downcase.to_sym
      raise ArgumentError "Supported mode are: 'split' or 'trim'" unless [:split, :trim].include? operation
      @@split_operation = operation
    end
  end
end