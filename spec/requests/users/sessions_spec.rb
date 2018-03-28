require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  # NOTE Only bothered testing custom methods. Don't need to test Devise itself.

  let(:au_1) { create(:accounts_user) }
  let(:account_1) { au_1.account }
  let(:user_1) { au_1.user }

  let(:au_2) { create(:accounts_user, user: user_1) }
  let(:account_2) { au_2.account }

  before do
    host! 'lvh.me:3000'
  end

  describe '#create' do
    let(:au_disabled) { create(:accounts_user, disabled_at: 1.second.ago) }
    let(:account) { au_disabled.account }
    subject do
      post new_user_session_url(au_disabled.account.subdomain), params: {
        user: { email: au_disabled.email, password: 'password' }
      }
    end
  end

  describe 'accept invitation' do
    let!(:invited_user) do
      raw, enc = Devise.token_generator.generate(User, :invitation_token)
      @raw_invitation_token = raw
      user = build(:user, :invited, invitation_token: enc)
      user.being_invited! account_1.id
      user.save
      user
    end

    subject do
      get accept_user_invitation_path, params: { invitation_token: @raw_invitation_token }
      response
    end

    it 'renders devise/invitations/edit' do
      expect(subject).to have_http_status(:success)
      expect(subject).to render_template('devise/invitations/edit')
      expect(flash[:alert]).to be_nil
    end
  end

  describe 'after_sign_in_path_for' do
    subject do
      post new_user_session_path, params: {
        user: { email: user_1.email, password: 'password' }
      }
    end

    context 'without account subdomain in host' do
      before { host! 'lvh.me:3000' }

      it 'redirects to first account with lower ID' do
        expect(subject).to redirect_to(
          dashboard_url(subdomain: account_1.subdomain)
        )
      end
    end

    context 'with account subdomain in host' do
      before { host! "#{account_2.subdomain}.lvh.me:3000" }

      it 'redirects to provided account' do
        expect(subject).to redirect_to(
          dashboard_url(subdomain: account_2.subdomain)
        )
      end
    end
  end

  describe 'find_workspace' do
    context 'submitting valid subdomain' do
      subject { post find_workspace_path, params: { subdomain: account_1.subdomain } }
      it 'redirects to provided subdomain' do
        expect(subject).to redirect_to(new_user_session_url(subdomain: account_1.subdomain))
      end
    end

    context 'landing at subdomain login' do
      subject { post find_workspace_path, params: { subdomain: 'nope' } }
      it 'renders new with flash error' do
        expect(subject).to render_template('devise/sessions/new')
        expect(flash[:error]).to match /That workspace was not found/
      end
    end
  end
end
