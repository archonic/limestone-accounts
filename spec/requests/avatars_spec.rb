require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe AvatarsController, type: :request do
  let(:au) { create(:accounts_user) }
  let(:user) { au.user }
  let(:file) { fixture_file_upload("#{fixture_path}/files/money_sloth.png") }
  before do
    host! "#{au.account.subdomain}.lvh.me:3000"
  end

  describe '#update' do
    subject do
      patch avatars_path, params: { user: { avatar: file } }
      response
    end

    context 'as some rando' do
      it 'responds with unauthorized' do
        expect{ subject }.to raise_error(ActionController::RoutingError)
      end
    end

    context 'as authenticated user' do
      before { sign_in user }

      it 'creates avatar for user' do
        expect(subject).to have_http_status(:redirect)
        expect(flash[:notice]).to match 'Avatar updated'
        expect(user.avatar.variant(:xs).blob.filename.to_s).to eq file.original_filename
      end
    end
  end

  describe '#destroy' do
    before { sign_in user }
    subject do
      delete avatar_path
      response
    end

    it 'removes the avatar' do
      expect(user.avatar).to receive(:purge).once
      expect(subject).to have_http_status(:redirect)
      expect(flash[:notice]).to match 'Avatar deleted'
    end
  end
end
