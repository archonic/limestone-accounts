require 'rails_helper'

RSpec.describe Users::InvitationsController, type: :request do
  let!(:au) { create(:accounts_user, :subscribed) }
  let(:account) { au.account }
  let(:user) { au.user }
  let(:email_valid) { Faker::Internet.email }
  let(:email_invalid) { 'nope' }

  describe '#create' do
    before do
      host! "#{account.subdomain}.lvh.me"
      sign_in user
    end
    subject do
      post user_invitation_path, params: { user: { email: email_valid } }
      response
    end

    it 'calls mass_invite!' do
      allow(UserInvitationService).to receive(:mass_invite!).with(
        account,
        [email_valid]
      ).and_return({
        users_failed: [],
        users_successful: [User.new(email: email_valid)]
      })
      expect(UserInvitationService).to receive(:mass_invite!).with(
        account,
        [email_valid]
      ).once
      subject
    end

    context 'with a valid email' do
      it 'succeeds' do
        subject
        expect(flash[:success]).to match /successfully invited./
        expect(flash[:error]).to be_nil
      end
    end

    context 'with an invalid email' do
      subject do
        post user_invitation_path, params: { user: { email: email_invalid } }
      end

      it 'fails' do
        subject
        expect(flash[:success]).to be_nil
        expect(flash[:emails_failed]).to eq [email_invalid]
      end
    end
  end
end
