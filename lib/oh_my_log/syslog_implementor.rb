require_relative 'syslog_configuration'
module OhMyLog
  class SyslogImplementor
    include "::SyslogProcessors::#{OhMyLog::SyslogConfiguration.processor_name.upcase}".constantize
    attr_accessor :facility, :severity

    def initialize(hostname: nil, priority: nil, facility: nil, severity: nil, tag: nil)
      @hostname = hostname
      @priority = priority
      @facility = facility
      @severity = severity
      @tag = tag
    end

    def new_using(processor_name)
      OhMyLog::SyslogConfiguration.use(processor_name)
      return SyslogImplementor.new(hostname: @hostname, priority: @priority, facility: @facility, severity: @severity, tag: @tag)
    end
  end
end