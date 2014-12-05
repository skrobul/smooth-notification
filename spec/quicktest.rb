require 'pry'
require 'ostruct'
require_relative '../lib/notification_pipe'
class SlowNotifier ; def notify(msg) ; puts "sn_started" ; sleep 5; puts "MSG: #{msg.text} TYPE: #{msg.type}" ; end ; end
@msg1 = OpenStruct.new(:text => 'pierwszy tekst', :type => :clear)
@msg1 = OpenStruct.new(:text => 'drugi tekst', :type => :clear)
@np = NotificationPipe.new(:notifier => SlowNotifier.new, :clearing_interval => 5)
