require_relative "./time_providers"
require_relative './aggregated_message'
require_relative './clearmsg_handler'
require 'celluloid/autostart'


class NotificationPipe
  include Celluloid

  def initialize(opts={})
    @notifier = opts.fetch(:notifier)
    @deluge_threshold = opts.fetch(:deluge_threshold, 60)
    @clearing_interval = opts.fetch(:clearing_interval, 60)
    @timesrc = opts.fetch(:timesrc, NormalTimeProvider.new)
    @last_problem_notification = nil
    start_clearmsg_handler
  end

  def process(msg)
    # require 'pry'; binding.pry
    case msg.type
      when :problem
        send_deluge_notification(msg) if deluge_timer_expired?
      when :clear
        @clear_msg_handler.async.handle msg
    end
  end

  private
    def start_clearmsg_handler
      @clear_msg_handler = ClearMessageHandler.new(@notifier, @clearing_interval)
      @clear_msg_handler.async.handle_messages
    end

    def send_deluge_notification(msg)
      @last_problem_notification = @timesrc.now
      @notifier.notify msg
    end

    def deluge_timer_expired?
      @last_problem_notification.nil? || @timesrc.now >= (@last_problem_notification + @deluge_threshold)
    end
end
