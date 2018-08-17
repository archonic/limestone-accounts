require 'rails_helper'

RSpec.describe Notification, type: :model do

  it "has valid factory" do
    expect(build(:notification)).to be_valid
  end

  # callbacks
  describe "#trigger_notification_relay_worker" do
    let(:notification) { create(:notification) }

    it "calls relay worker" do
      expect(NotificationRelayWorker).to receive(:perform_async).once.with(
        instance_of(Integer),
        "create"
      )
      notification
      expect(NotificationRelayWorker).to receive(:perform_async).once.with(
        notification.id,
        "read"
      )
      notification.update(read: true)
    end
  end

  # methods
  describe "#target" do
    let(:notification) { create(:notification) }

    it "returns path for notification target" do
      # NOTE test all cases as you add them
      expect(notification.target).to eq "#fill_out_target_in_notification.rb"
    end
  end

end
