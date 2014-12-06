require_relative './spec_helper'
require_relative '../lib/notification_pipe.rb'

describe NotificationPipe do
  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
  end


  let(:clear_msg) { double(text: 'something cleared', type: :clear)}
  let(:problem_msg) { double(text: 'something broke', type: :problem)}

  context 'when msg is a problem' do
    let(:notifier) { spy() }
    subject(:npipe) { NotificationPipe.new(:deluge_threshold => 2, :notifier => notifier) }
    context 'and arrives before timer expiration and max_mesages is not exceeded' do
      it 'runs notification' do
        npipe.process_incoming_line 'something is down|problem'
        expect(notifier).to have_received(:notify).exactly(:once).with(Notification)
      end
    end

    context 'when more than max_threshold messages arrive in same period' do
      let(:notifier) { spy() }
      subject(:npipe) { NotificationPipe.new(:deluge_threshold => 2, :notifier => notifier) }
      it 'sends only first max_threshold and ignores the rest' do
        20.times { npipe.process_incoming_line 'something is down|problem' }
        expect(notifier).to have_received(:notify).exactly(10).with(Notification)
      end
    end

    context 'when the timer expires after initial threshold is triggered' do
      subject(:npipe) { NotificationPipe.new(:deluge_threshold => 2, :notifier => notifier) }
      let(:t1) { Time.local(2015, 9, 1, 13, 0, 0) }
      let(:t2) { Time.local(2015, 9, 1, 13, 10, 0) }
      let(:notifier) { spy() }

      before { Timecop.freeze(t1) }
      after  { Timecop.return }

      it 'delivers remaining messages and sleeps before that' do
        50.times { npipe.process_incoming_line 'something is down|problem' }
        Timecop.travel(t2)
        30.times { npipe.process_incoming_line 'something is down|problem' }
        expect(notifier).to have_received(:notify).exactly(20).with(Notification)
      end
    end
  end

  context 'when msg is a clearmsg' do
    let(:notifier) { spy() }
    subject(:npipe) { NotificationPipe.new(:clearing_interval => 10, :notifier => notifier) }

    describe 'single message' do
      xit 'sends a notification' do
        expect(Kernel).to receive(:sleep).at_least(:once)
        npipe.process_incoming_line 'host1 is up|clear'
        expect(notifier).to have_received(:notify).exactly(:once)
      end
    end
  end
  # describe "#process" do
  #   let(:threshold) { 60 }
  #   let(:notifier) { spy() }
  #   let(:clear_msg) { double(text: 'something cleared', type: :clear)}
  #   let(:problem_msg) { double(text: 'something broke', type: :problem)}
  #
  #   before(:each) do
  #     @faketime = FakeTimeProvider.new
  #     @npipe = NotificationPipe.new(:deluge_threshold => threshold,
  #                                   :clearing_interval => threshold,
  #                                   :notifier => notifier,
  #                                   :timesrc => @faketime)
  #   end
  #
  #
  #   context "when type is problem" do
  #
  #     context "when the notification arrives before timer expires and no alerts were sent in this period" do
  #       it 'sends the message immedaitely' do
  #         @npipe.process problem_msg
  #         expect(notifier).to have_received(:notify).with(problem_msg).exactly(:once)
  #       end
  #     end
  #     context "when the notification arrives before timer expires and alert has been sent already" do
  #       it 'does not send more messages' do
  #         @npipe.process problem_msg
  #         @npipe.process problem_msg
  #         @npipe.process problem_msg
  #         @npipe.process problem_msg
  #         @npipe.process problem_msg #consequent message that should be ignored
  #         expect(notifier).to have_received(:notify).with(problem_msg).exactly(:once)
  #       end
  #     end
  #     context "when the notifications arrive before timer expires and alert has been sent already" do
  #       it 'does not send more messages' do
  #         10.times { @npipe.process problem_msg  }
  #         @faketime.advance threshold
  #         5.times { @npipe.process problem_msg }
  #         @npipe.process problem_msg #consequent message that should be ignored
  #         expect(notifier).to have_received(:notify).with(problem_msg).exactly(:twice)
  #       end
  #     end
  #   end
  #   context "when type is clear " do
  #     context 'when just single message arrives within period' do
  #       let(:expected_aggregated_msg) { AggregatedMessage.new([clear_msg], :clear)}
  #       it 'sends message out one aggregated notification' do
  #         @npipe.process clear_msg
  #         @faketime.advance threshold + 1
  #         expect(notifier).to have_received(:notify).exactly(:once).with([expected_aggregated_msg])
  #       end
  #     end
  #     context 'when multiple messages arrive within period' do
  #       let(:expected_aggregated_msg) { AggregatedMessage.new([clear_msg] * 10, :clear)}
  #       it 'should be aggregated' do
  #         10.times { @npipe.process clear_msg }
  #         @faketime.advance threshold
  #         expect(notifier).to have_received(:notified).with(expected_aggregated_msg)
  #       end
  #     end
  #   end
  # end
end
