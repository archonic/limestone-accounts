require 'rails_helper'

RSpec.describe AccountsController, type: :request do
  let(:email_valid) { Faker::Internet.email }
  let(:email_invalid) { 'nope' }
  let(:plan) { create(:plan) }
  let(:valid_account_params) do
    {
      plan_id: plan.id,
      name: 'Name',
      subdomain: 'subdomain',
      owner_attributes: {
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

      it 'assigns the role of admin to the owner' do
        subject
        expect(Account.find_by(subdomain: 'subdomain').owner.has_role? :admin).to eq true
      end
    end

    context 'with bad params' do
      context 'invalid plan_id' do
        let(:account_params) { valid_account_params.except :plan_id }

        it 'errors on plan_id' do
          subject
          expect(flash[:error]).to match /Problem/
        end
      end
    end
  end
end
