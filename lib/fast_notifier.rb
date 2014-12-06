class FastNotifier
  def notify(msg)
     puts "fn_started"
     puts "MSG: #{msg.text} TYPE: #{msg.notification_type}"
     puts 'fn_end'
  end
end
