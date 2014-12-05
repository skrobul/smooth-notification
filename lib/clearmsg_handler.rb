require 'celluloid'
require_relative './aggregated_message.rb'
class ClearMessageHandler
  include Celluloid

  def initialize(notifier, clearing_interval, timesrc)
    @notifier = notifier
    @timesrc = timesrc
    @msgs = []
    @clearing_interval = clearing_interval
  end

  def handle(msg)
    @msgs << msg
  end

  def handle_messages
    # @timesrc.sleep @clearing_interval
    sleep @clearing_interval
    send_all_messages_in_the_buffer
  end

  def terminate
    send_all_messages_in_the_buffer
  end

  private

  def clear_message_queue
    @msgs = []
  end

  def send_all_messages_in_the_buffer
    if @msgs.size > 0
      aggregated_messsage = AggregatedMessage.new(@msgs, :clear)
      clear_message_queue
      @notifier.notify aggregated_messsage
    end
    async.handle_messages
  end

end
