class Notification
  attr_reader :text, :notification_type

  def initialize(msg, notification_type)
    proposed_type = notification_type.chomp.to_sym
    @notification_type = proposed_type if valid_type?(proposed_type)
    @text = msg
  end

  def valid_type?(notification_type)
    if [:problem, :clear].include?(notification_type)
      true
    else
      raise "Wrong Notification type: #{notification_type}. Allowed values are :problem and :clear"
    end
  end

  def self.from_text(text)
    instance = allocate
    return nil unless text.include?('|')
    tokenized_text = text.split('|')
    notification_type = tokenized_text.pop
    msg = tokenized_text.join('|')
    instance.send(:initialize, msg, notification_type)
    instance
  end
end
