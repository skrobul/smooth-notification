require_relative "./time_providers"
require_relative './aggregated_message'
require_relative './clearmsg_handler'
require_relative './problem_handler'
require_relative './notification'
require 'celluloid'
require 'celluloid/io'


class NotificationPipe
  include Celluloid::IO
  finalizer :finalize

  def initialize(opts={})
    @notifier = opts.fetch(:notifier)
    @socket_path = opts.fetch(:socket, '/tmp/smooth-notification.sock')
    @socket = UNIXServer.open(@socket_path)

    @deluge_threshold = opts.fetch(:deluge_threshold, 60)
    @clearing_interval = opts.fetch(:clearing_interval, 60)

    @timesrc = opts.fetch(:timesrc, NormalTimeProvider.new)
    @last_problem_notification = nil
    start_clearmsg_handler
    start_problem_msg_handler
  end

  def handle_incoming_connection(socket)
   # puts  'Incoming connection.'
   loop { process_incoming_line(socket.readline) }
   rescue EOFError
     # puts 'Notification client disconnected' #Only for debug
   ensure
     socket.close
  end

  def process_incoming_line(line)
    msg = Notification.from_text(line)
    # require 'pry'; binding.pry
    case msg.notification_type
      when :problem
        @problem_msg_handler.async.handle msg
      when :clear
        @clear_msg_handler.async.handle msg
    end
  end

  def run
    loop { async.handle_incoming_connection @socket.accept }
  end

  def finalize
    if @socket
      @socket.close
      File.delete(@socket_path)
    end
    @clear_msg_handler.terminate if @clear_msg_handler.alive?
    @problem_msg_handler.terminate if @problem_msg_handler.alive?
  end

  private
    def start_clearmsg_handler
      @clear_msg_handler = ClearMessageHandler.new(@notifier, @clearing_interval, @timesrc)
      @clear_msg_handler.async.handle_messages
    end

    def start_problem_msg_handler
      @problem_msg_handler = ProblemMessageHandler.new(@notifier, @deluge_threshold, @timesrc)
      # @problem_msg_handler.async.handle_messages
    end
end


