require 'celluloid'


class ProblemMessageHandler
  include Celluloid

  def initialize(notifier, timeout, timesrc)
    @notifier = notifier
    @deluge_timeout = timeout
    @timesrc = timesrc
    @last_problem_notification = nil
  end

  def handle(msg)
    if deluge_timer_expired?
      @notifier.notify msg
      @last_problem_notification = @timesrc.now
    end
  end

  private
    def deluge_timer_expired?
      @last_problem_notification.nil? || @timesrc.now >= (@last_problem_notification + @deluge_timeout)
    end
end
