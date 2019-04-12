module OhMyLog
  class SyslogConfiguration
    @@processor_name = "RFC3164"

    def self.use(processor_name)
      raise "We don't support the #{processor_name} format" unless (("SyslogProcessors::#{processor_name.upcase}".constantize) rescue false)
      @@processor_name = processor_name
    end

    def self.processor_name
      return @@processor_name
    end
  end
end