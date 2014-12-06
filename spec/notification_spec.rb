require_relative '../lib/notification'


describe Notification do
  describe '#initialize' do
    context 'when type is incorrect' do
      it 'raises an exception' do
        expect{ Notification.new('msg', 'wrongtype') }.to raise_exception
      end
    end
    context 'when type is correct' do
      subject(:problem_notification) { Notification.new('my message', 'problem') }
      subject(:clear_notification) { Notification.new('clear msg', 'clear') }

      it { expect(problem_notification).to be_an Notification }
      it { expect(problem_notification).to have_attributes(:text => 'my message') }
      it { expect(problem_notification).to have_attributes(:notification_type => :problem) }

      it { expect(clear_notification).to be_an Notification }
      it { expect(clear_notification).to have_attributes(:text => 'clear msg') }
      it { expect(clear_notification).to have_attributes(:notification_type => :clear) }
    end
  end

  describe '#from_text' do
    context 'when line format is correct' do
      subject { Notification.from_text 'i am the correct message|problem'}
      it { is_expected.to be_an Notification }
      it { is_expected.to have_attributes(:text => 'i am the correct message') }
      it { is_expected.to have_attributes(:notification_type => :problem)}
    end

    context 'when provided with bogus data' do
      it 'does not work without at least one separator' do
        expect(Notification.from_text('empty text without type')).to be_nil
      end
    end
    context 'when message contains | signs' do
      subject { Notification.from_text 'this is a message with | in a text|problem'  }
      it { is_expected.to have_attributes(:text => 'this is a message with | in a text') }
      it { is_expected.not_to be_nil }
    end
  end
end
