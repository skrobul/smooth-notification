class AggregatedMessage
  attr_reader :text, :notification_type
  def initialize(msgs=[], notification_type)
    @text = msgs.collect(&:text).join("\n")
    @notification_type = notification_type
  end
end
