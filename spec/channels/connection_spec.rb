# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let!(:au) { create(:accounts_user) }
  let(:account) { au.account }
  let(:user) { au.user }

  it "successfully connects" do
    connect "/ws", cookies: {
      "user.id" => user.id,
      "user.expires_at" => 5.minutes.from_now
    }
    expect(connection.current_user).to eq user
  end

  it "rejects connection" do
    expect { connect "/ws" }.to have_rejected_connection
  end
end
