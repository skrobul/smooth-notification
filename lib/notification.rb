class Notification
  attr_reader :message, :type

  def initialize(msg, type)
    @msg = msg
    if [:problem, :clear].include?(type)
      @type = type
    else
      raise 'Wrong Notification type. Allowed values are :problem and :clear'
    end
  end
end
