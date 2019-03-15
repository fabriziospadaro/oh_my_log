# Effect is container of all the changes that a model suffers
module OhMyLog
  module Log
    class Effect
      attr_reader :receiver
      attr_reader :changes

      def initialize(receiver)
        @receiver = receiver
        @changes = receiver.previous_changes
      end

      def to_s
        "#{@receiver.class.to_s}[#{@receiver.id}] => #{@changes}"
      end
    end
  end
end