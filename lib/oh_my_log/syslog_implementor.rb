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
      if data[0].bytesize >= 1024
        if OhMyLog::SyslogConfiguration.split_operation.to_sym == :split
          id = SecureRandom.hex(8)
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
      remaining_string = string
      binary_chunks = []
      until remaining_string.empty?
        chunk = limit_bytesize(remaining_string, size)
        binary_chunks << chunk
        remaining_string = remaining_string[chunk.size..remaining_string.size]
      end
      binary_chunks
    end

    # https://stackoverflow.com/questions/12536080/ruby-limiting-a-utf-8-string-by-byte-length
    def limit_bytesize(str, size)
      str.encoding.name == 'UTF-8' or raise ArgumentError, "str must have UTF-8 encoding"

      # Change to canonical unicode form (compose any decomposed characters).
      # Works only if you're using active_support
      str = str.mb_chars.compose.to_s if str.respond_to?(:mb_chars)

      # Start with a string of the correct byte size, but
      # with a possibly incomplete char at the end.
      new_str = str.byteslice(0, size)

      # We need to force_encoding from utf-8 to utf-8 so ruby will re-validate
      # (idea from halfelf).
      until new_str[-1].force_encoding('utf-8').valid_encoding?
        # remove the invalid char
        new_str = new_str.slice(0..-2)
      end
      new_str
    end

    # def override_log_formatter
    #   OhMyLog::Log.configuration.log_instance.formatter = proc do |severity, datetime, progname, msg|
    #     "#{msg}\n"
    #   end
    # end

    def retrive_public_ip
      if Rails.env.test?
        "127.0.0.1"
      else
        Net::HTTP.get(URI("http://checkip.amazonaws.com")).gsub("\n", "") rescue nil
      end
    end

    def retrive_hostname
      Socket.gethostname rescue nil
    end
  end
end