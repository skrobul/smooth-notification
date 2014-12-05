require_relative '../lib/notification_pipe.rb'

describe NotificationPipe do
  describe "#process" do
    let(:threshold) { 60 }
    let(:notifier) { spy() }
    let(:clear_msg) { double(text: 'something cleared', type: :clear)}
    let(:problem_msg) { double(text: 'something broke', type: :problem)}

    before(:each) do
      @faketime = FakeTimeProvider.new
      @npipe = NotificationPipe.new(:deluge_threshold => threshold, :notifier => notifier, :timesrc => @faketime)
    end

    context "when the notification arrives before timer expires and no alerts were sent in this period" do
      it 'sends the message immedaitely' do
        @npipe.process problem_msg
        expect(notifier).to have_received(:notify).with(problem_msg).exactly(:once)
      end
    end
    context "when the notification arrives before timer expires and alert has been sent already" do
      it 'does not send more messages' do
        @npipe.process problem_msg
        @npipe.process problem_msg
        @npipe.process problem_msg
        @npipe.process problem_msg
        @npipe.process problem_msg #consequent message that should be ignored
        expect(notifier).to have_received(:notify).with(problem_msg).exactly(:once)
      end
    end
    context "when the notifications arrive before timer expires and alert has been sent already" do
      it 'does not send more messages' do
        10.times { @npipe.process problem_msg  }
        @faketime.advance threshold
        5.times { @npipe.process problem_msg }
        @npipe.process problem_msg #consequent message that should be ignored
        expect(notifier).to have_received(:notify).with(problem_msg).exactly(:twice)
      end
    end
  end
end
