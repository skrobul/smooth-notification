require_relative "./time_providers"
require_relative './aggregated_message'

class NotificationPipe
  def initialize(opts={})
    @notifier = opts.fetch(:notifier)
    @deluge_threshold = opts.fetch(:deluge_threshold, 60)
    @clearing_interval = opts.fetch(:clearing_interval, 60)
    @clear_buffer = []
    @timesrc = opts.fetch(:timesrc, NormalTimeProvider.new)
    @clear_buffer_last_flushed = @timesrc.now
    @last_problem_notification = nil
    start_clearing_thread
  end

  def process(msg)
    # require 'pry'; binding.pry
    case msg.type
      when :problem
        send_deluge_notification(msg) if deluge_timer_expired?
      when :clear
        if clear_timer_expired?
          empty_clear_buffer
        else
          add_clearmsg_to_buffer msg
        end
    end
  end

  private
    def start_clearing_thread
      # TODO: convert me to celluloid !
      @t = Thread.new do
        @timesrc.sleep(@clearing_interval)
        empty_clear_buffer
      end
    end
    def send_deluge_notification(msg)
      @last_problem_notification = @timesrc.now
      @notifier.notify msg
    end

    def deluge_timer_expired?
      @last_problem_notification.nil? || @timesrc.now >= (@last_problem_notification + @deluge_threshold)
    end

    def clear_timer_expired?
      @timesrc.now >= (@clear_buffer_last_flushed + @clearing_interval)
    end

    def empty_clear_buffer
      aggregated_messsage = AggregatedMessage.new(@clear_buffer)
      @notifier.notify aggregated_messsage
    end

    def add_clearmsg_to_buffer(msg)
      @clear_buffer << msg
    end
end
