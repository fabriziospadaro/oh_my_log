module SyslogProcessors
  module RFC3164
    def calculate_priority
      self.class.calculate_priority(facility: @facility, severity: @severity)
    end

    def priority_text
      return "<#{@priority || calculate_priority}>"
    end

    def message_text(ip:, user:, url:, m:, s:, p:)
      text = "#{@tag.upcase}:"
      text += "ip=#{ip};"
      text += "u=#{user};"
      text += "url=#{url};"
      text += "m=#{m};"
      text += "s=#{s};"
      text += "p=#{p};"
      text
    end

    def header_text(request_time)
      #request_time.to_time. + " #{@hostname}"
      request_time.strftime("%b %-d %H:%M:%S") + " #{@public_ip || @hostname || "FAK"}"
    end

    def print(params)
      priority_text + header_text(params[:request_time]) + " " + message_text(params.reject {|k| k == :request_time})
    end

    def self.calculate_priority(facility: nil, severity: nil)
      raise "You  need facility and severity to calculate the priority" unless facility && severity
      facility * 8 + severity
    end
  end
end