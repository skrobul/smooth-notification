require 'celluloid'


class ProblemMessageHandler
  include Celluloid

  def initialize(notifier, threshold, timesrc)
    @notifier = notifier
    @deluge_threshold = threshold
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
      @last_problem_notification.nil? || @timesrc.now >= (@last_problem_notification + @deluge_threshold)
    end
end
