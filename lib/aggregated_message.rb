class AggregatedMessage
  attr_reader :text, :type
  def initialize(msgs=[], type)
    @text = msgs.collect(&:text).join("\n")
    @type = type
  end
end
