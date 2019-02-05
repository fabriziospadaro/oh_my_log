module OhMyLog
  module Log
#the request is what the user is trying to do
    class Request
      attr_reader :sender, :date, :params, :method, :status

      def initialize(args)
        @sender = args[:sender]
        @date = args[:date]
        @params = args[:params]
        @method = args[:method]
        @status = args[:status]
      end

      def to_s
        user_info = @sender.try(:email)
        sender = !user_info.blank? ? user_info : Thread.current["remote_ip"]
        "#{@date}, #{sender}, #{@method}, #{@params}, #{@status}"
      end
    end
  end
end