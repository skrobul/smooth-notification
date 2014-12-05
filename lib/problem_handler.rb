require 'celluloid'


class ProblemMessageHandler
  include Celluloid

  def initialize(notifier, timeout, timesrc, max_messages=10)
    @notifier = notifier
    @deluge_timeout = timeout
    @timesrc = timesrc
    @last_problem_notification = nil
    @max_messages = max_messages
    @msgs_in_this_period = 0
  end

  def handle(msg)
    if new_message_allowed?
      @notifier.notify msg
      @last_problem_notification = @timesrc.now
      @msgs_in_this_period += 1
    end
  end

  private

    def new_message_allowed?
      (@msgs_in_this_period < @max_messages) || deluge_timer_expired?
    end

    def deluge_timer_expired?
      @last_problem_notification.nil? || @timesrc.now >= (@last_problem_notification + @deluge_timeout)
    end
end
