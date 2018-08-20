# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe InvoicesController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(
      id: "example-plan-id",
      name: "World Domination",
      amount: 100_000,
      trial_period_days: TRIAL_PERIOD_DAYS
    )
    host! "#{account.subdomain}.lvh.me:3000"
  end
  after { StripeMock.stop }
  # let(:mock_customer) { Stripe::Customer.create }
  # let(:mock_subscription) { mock_customer.subscriptions.create(plan: "example-plan-id") }
  let!(:au) { create(:accounts_user, :subscribed) }
  let(:user) { au.user }
  let(:account) { au.account }
  let(:invoice) do
    Apartment::Tenant.switch(account.subdomain) do
      create(:invoice, account_id: account.id)
    end
  end

  describe "GET /invoices/:id" do
    subject do
      get invoice_path(invoice.id, format: :pdf)
      response
    end

    context "as a subscribed user" do
      before { sign_in user }

      it "serves an invoice PDF" do
        expect(subject).to have_http_status(:success)
        expect(subject.header["Content-Type"]).to eq "application/pdf"
      end
    end
  end
end
