require 'rails_helper'
require 'stripe_mock'

RSpec.describe SubscriptionsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'example-plan-id', name: 'World Domination', amount: 100000, currency: 'usd', trial_period_days: $trial_period_days)
  end
  after { StripeMock.stop }

  let!(:au_no_subscription) { create(:accounts_user) }
  let(:account_no_subscription) { au_no_subscription.account }
  let(:user_no_subscription) { au_no_subscription.user }

  let!(:au_subscribed) { create(:accounts_user, :subscribed) }
  let(:account_subscribed) { au_subscribed.account }
  let(:user_subscribed) { au_subscribed.user }

  describe 'GET billing_path' do
    subject do
      get billing_path
      response
    end

    context 'as an account with no subscription' do
      before do
        host! "#{account_no_subscription.subdomain}.lvh.me"
        sign_in user_no_subscription
      end

      # NOTE saw a transient failure here
      it 'redirects to subscribe page' do
        expect(subject).to redirect_to subscribe_path
      end
    end

    context 'as a subscribed account' do
      before do
        host! "#{account_subscribed.subdomain}.lvh.me"
        sign_in user_subscribed
      end

      it 'shows card on file' do
        expect(subject).to have_http_status(:success)
        expect(subject.body).to include 'Visa **** **** **** 1234'
        expect(subject.body).to include 'Expires 2 / 2025'
      end

      it 'shows next payment' do
        expect(subject.body).to include 'Your card will be charged'
        expect(subject.body).to include account_subscribed.cost
        expect(subject.body).to include "on #{account_subscribed.current_period_end.strftime('%A, %B %e, %Y')}"
      end
    end
  end

  describe 'PATCH /subscriptions' do
    subject do
      patch subscriptions_path, params: {
        stripeToken: stripe_helper.generate_card_token,
        card_brand: 'MasterCard',
        card_exp_month: 12,
        card_exp_year: 2024,
        card_last4: 4444
      }
      response
    end

    context 'as an account with no subscription' do
      before do
        host! "#{account_no_subscription.subdomain}.lvh.me"
        sign_in user_no_subscription
        Apartment::Tenant.switch('public') { user_no_subscription.accounts_user(account_no_subscription).add_role :admin }
      end
      it 'redirects to root with access denied' do
        expect(subject).to redirect_to subscribe_path
        expect(flash[:error]).to match 'There was an error updating your subscription'
      end
    end

    context 'as a subscribed account' do
      let(:mock_customer) { Stripe::Customer.create }
      let!(:mock_subscription) { mock_customer.subscriptions.create(plan: 'example-plan-id') }

      before do
        host! "#{account_subscribed.subdomain}.lvh.me"
        sign_in user_subscribed
      end

      context 'with good params' do
        it 'updates the existing subscription' do
          expect(subject).to redirect_to billing_path
          expect(flash[:success]).to match 'Subscription updated'
        end
      end

      context 'with no stripe token and no plan' do
        it 'does not update user but reports success' do
          expect(user_subscribed).to_not receive(:update)
          patch subscriptions_path, params: {
            card_brand: 'MasterCard',
            card_exp_month: 12,
            card_exp_year: 2024,
            card_last4: 4444
          }
          expect(response).to redirect_to billing_path
          # Although no changes were made, there were no errors.
          # Success response indicates that current data is correct
          expect(flash[:success]).to match 'Subscription updated'
        end
      end
    end
  end
end
