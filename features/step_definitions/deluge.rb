Given(/^server sends (\d+) notification$/) do |arg1|
  @npipe = NotificationPipe.new
  @msg = { :msg => "This is a message", :type => :problem }
end

When(/^there was no notifications sent within last hour$/) do
  @npipe.last_message < (Time.now - threshold)
end

Then(/^notification is sent$/) do
  @npipe.process(@msg) == :sent
end






Given(/^server sends notification$/) do
  @npipe = NotificationPipe.new
  @msg = { :msg => "This is a message", :type => :problem }
end

When(/^system released less than MAX messages during TIME_THRESHOLD$/) do
  @npipe.last_message < (Time.now - threshold)
end

When(/^number of messages sent within notification period is larger than allowed$/) do
  @npipe.remaining_messages < 1
end

Then(/^message is ignored$/) do
  @npipe.process(@msg) == :not_sent
end

Given(/^server sends two messages$/) do
  @msg1 = { :msg => "This is a message", :type => :problem }
end

When(/^time between two messages is larger than threshold$/) do
  @msg2.timestamp
end

Then(/^both messages are sent$/) do
  pending # express the regexp above with the code you wish you had
end
