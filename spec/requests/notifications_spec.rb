# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationsController, type: :request do
  let!(:au) { create(:accounts_user, :subscribed) }
  let(:user) { au.user }
  let(:account) { au.account }

  before do
    host! "#{account.subdomain}.lvh.me:3000"
    sign_in(user)
  end

  describe "dropdown" do
    subject do
      get notifications_dropdown_path
      response
    end

    it "renders dropdown" do
      expect(subject).to have_http_status(:success)
      expect(subject).to render_template("notifications/dropdown")
    end
  end

  describe "read" do
    let(:notification) do
      Apartment::Tenant.switch(account.subdomain) { create(:notification, recipient: user) }
    end
    subject do
      post notification_read_path(notification.id)
    end

    it "marks notification as read" do
      Apartment::Tenant.switch(account.subdomain) do
        expect(notification.read).to be false
        subject
        expect(notification.reload.read).to be true
      end
    end
  end
end
