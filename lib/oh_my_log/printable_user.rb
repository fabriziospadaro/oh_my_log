class PrintableUser
  DEFAULT_FIELDS = ["email", "full_name", ["first_name", "last_name"], "id"].freeze

  def initialize(user, accepted_values)
    raise "DIO" unless accepted_values
    raise ArgumentError unless user || !accepted_values.is_a?(Array)
    @user = user
    @accepted_values = accepted_values
  end

  def to_s
    try_val = ->(val) do
      user.send(val.to_sym) rescue nil
    end
    accepted_values.each do |val|
      if val.is_a?(Array)
        tmp_val = val.map {|field| try_val.call(field)}.join(" ")
        return tmp_val if tmp_val.present?
      elsif [String, Symbol].include?(val.class)
        return try_val.call(val) if try_val.call(val)
      else
        raise ArgumentError
      end
    end
    raise "No values was found"
  end

  private

  attr_reader :user, :accepted_values

end