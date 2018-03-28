require 'rails_helper'
require 'stripe_mock'

RSpec.describe AccountsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'example-plan-id', name: 'Pro', amount: 1500, currency: 'usd', trial_period_days: $trial_period_days)
    # Allow public registration before testing it
    $flipper.enable :public_registration
  end
  after { StripeMock.stop }

  let(:email_valid) { Faker::Internet.email }
  let(:email_invalid) { 'nope' }
  let(:plan) { create(:plan) }
  let(:valid_account_params) do
    {
      plan_id: plan.id,
      name: 'Name',
      subdomain: 'subdomain',
      owner_au_attributes: {
        user_attributes: {
          email: email_valid,
          first_name: 'Jane',
          last_name: 'Doe',
          password: 'password'
        }
      }
    }
  end

  describe '#create' do
    subject do
      post accounts_path, params: { account: account_params }
      response
    end

    context 'with good params' do
      let(:account_params) { valid_account_params }

      it 'creates the account' do
        expect(Account.find_by(subdomain: 'subdomain').nil?).to be true
        subject
        expect(Account.find_by(subdomain: 'subdomain').present?).to eq true
      end

      it 'redirects to account dashboard with success message' do
        expect(subject).to redirect_to(new_user_session_url(subdomain: 'subdomain'))
      end

      it 'mails the owner with a welcome message' do
        welcome_email_dbl = double(ActionMailer::MessageDelivery)
        allow(UserMailer).to receive(:welcome_email).and_return(welcome_email_dbl)
        expect(welcome_email_dbl).to receive(:deliver_later).once
        subject
      end

      it 'assigns admin role and populates invitation_accepted_at for owner' do
        subject
        owner = Account.find_by(subdomain: 'subdomain').owner
        expect(owner.has_role? :admin).to eq true
        expect(owner.user.invitation_accepted_at).to be_present
      end

      it 'creates the subscription in Stripe' do
        subscription_service_dbl = double(SubscriptionService)
        allow(SubscriptionService).to receive(:new).with(
          an_instance_of(Account),
          an_instance_of(Hash)
        ).and_return(subscription_service_dbl)
        expect(subscription_service_dbl).to receive(:create_subscription).once
        subject
      end
    end

    context 'with bad params' do
      context 'invalid plan_id' do
        let(:account_params) { valid_account_params.except :plan_id }

        it 'errors on plan_id' do
          expect(subject).to render_template('accounts/new')
        end
      end
    end
  end

  describe '#destroy' do
    let!(:au) { create(:accounts_user, :subscribed) }
    let(:account) { au.account }
    let(:user) { au.user }
    before do
      Apartment::Tenant.switch('public') { au.add_role :admin }
      host! "#{account.subdomain}.lvh.me:3000"
      sign_in user
    end
    subject do
      delete account_destroy_path
    end

    it 'cancels subscription with stripe' do
      subscription_service_dbl = double(SubscriptionService)
      allow(SubscriptionService).to receive(:new).with(
        account
      ).and_return(subscription_service_dbl)
      expect(subscription_service_dbl).to receive(:destroy_subscription).once
      subject
    end

    it 'discards account' do
      expect(account.discarded_at).to be_nil
      subject
      expect(account.reload.discarded_at).to be_present
    end
  end
end
