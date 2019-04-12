require_relative 'syslog_configuration'
require 'net/http'
module OhMyLog
  class SyslogImplementor
    include "::SyslogProcessors::#{OhMyLog::SyslogConfiguration.processor_name.upcase}".constantize
    attr_accessor :facility, :severity
    attr_reader :public_ip

    def initialize(hostname: nil, priority: nil, facility: nil, severity: nil, tag: nil)
      @hostname = retrive_hostname
      @public_ip = retrive_public_ip
      @priority = priority
      @facility = facility
      @severity = severity
      @tag = tag
      override_log_formatter
    end

    def new_using(processor_name)
      OhMyLog::SyslogConfiguration.use(processor_name)
      return SyslogImplementor.new(hostname: @hostname, priority: @priority, facility: @facility, severity: @severity, tag: @tag)
    end

    private

    def override_log_formatter
      OhMyLog::Log.configuration.log_instance.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end

    def retrive_public_ip
      Net::HTTP.get(URI("http://checkip.amazonaws.com")).gsub("\n", "") rescue nil
    end

    def retrive_hostname
      Socket.gethostname rescue nil
    end
  end
end