require_relative "./time_providers"

class NotificationPipe
  def initialize(opts={})
    @notifier = opts.fetch(:notifier)
    @deluge_threshold = opts.fetch(:deluge_threshold, 60)
    @clearing_interval = opts.fetch(:clearing_interval, 60)
    @clear_buffer = []
    @timesrc = opts.fetch(:timesrc, NormalTimeProvider.new)
    @clear_buffer_last_flushed = @timesrc.now
    @last_problem_notification = nil
  end

  def process(msg)
    if msg.type == :problem
      # require 'pry'; binding.pry
      if @last_problem_notification.nil? or @timesrc.now >= (@last_problem_notification + @deluge_threshold)
        @last_problem_notification = @timesrc.now
        @notifier.notify msg
      end
    end
  end
end
