module OhMyLog
  module Log
    #the request is what the user is trying to do
    class Request
      attr_reader :sender, :date, :params, :method, :status, :path

      def initialize(args)
        @sender = args[:sender]
        @date = args[:date]
        @params = args[:params]
        @method = args[:method]
        @status = args[:status]
        @path = args[:path]
      end

      def to_s
        user_info = PrintableUser.new(@sender, OhMyLog::Log.configuration.user_fields) rescue nil
        sender = user_info || Thread.current["remote_ip"]
        "#{@date}, #{sender}, #{@method}, #{@params}, #{@status}"
      end
    end
  end
end