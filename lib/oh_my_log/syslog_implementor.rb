require_relative 'syslog_configuration'
require 'net/http'
require 'syslog/logger'
require 'securerandom'

module OhMyLog
  class SyslogImplementor
    include "::SyslogProcessors::#{OhMyLog::SyslogConfiguration.processor_name.upcase}".constantize
    attr_accessor :facility, :severity
    attr_reader :public_ip, :tag

    def initialize(hostname: nil, priority: nil, facility: nil, severity: nil, tag: nil, program_name: "NA", syslog_facility: "Syslog::LOG_LOCAL1")
      @hostname = retrive_hostname
      @public_ip = retrive_public_ip
      @priority = priority
      @facility = facility
      @severity = severity
      @tag = tag
      @program_name = program_name
      @syslog_facility = syslog_facility
      OhMyLog::Log.configuration.log_instance = Syslog::Logger.new program_name, syslog_facility.constantize
      # override_log_formatter
    end

    def new_using(processor_name)
      OhMyLog::SyslogConfiguration.use(processor_name)
      SyslogImplementor.new(hostname: @hostname, priority: @priority, facility: @facility, severity: @severity, tag: @tag, program_name: @program_name, syslog_facility: @syslog_facility)
    end

    #TODO no need to pass :ip we can retrieve it from this class
    def print(params)
      data = [super(params)]
      id = SecureRandom.hex(8)
      if data[0].bytesize >= 1024
        if OhMyLog::SyslogConfiguration.split_operation == :split
          message = message_text(ip: params[:ip], user: params[:sender], url: params[:url], m: params[:m], s: params[:s], p: params[:p])
          data = []
          priority = priority_text
          header = header_text(params[:request_time])
          base_msg = priority + header + "#{@tag}[ID=#{id}]:"
          remaining_byte = 1023 - base_msg.bytesize
          message_chunks = get_binary_chunks(message, remaining_byte)
          message_chunks.each {|chunk_data| data << base_msg + chunk_data + ";"}
        else
          data[0] = get_binary_chunks(data[0], 1021)[0] + "..."
        end
      end
      data
    end

    private

    def get_binary_chunks(string, size)
      Array.new(((string.length + size - 1) / size)) {|i| string.byteslice(i * size, size)}
    end

    # def override_log_formatter
    #   OhMyLog::Log.configuration.log_instance.formatter = proc do |severity, datetime, progname, msg|
    #     "#{msg}\n"
    #   end
    # end

    def retrive_public_ip
      Net::HTTP.get(URI("http://checkip.amazonaws.com")).gsub("\n", "") rescue nil
    end

    def retrive_hostname
      Socket.gethostname rescue nil
    end
  end
end