require 'rails_helper'
require 'stripe_mock'

RSpec.describe CreateAdminService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#call' do
    before do
      create(:plan)
      create(:account, subdomain: "limestone")
    end

    let(:account) { Account.find_by(subdomain: "limestone") }

    it 'creates the admin' do
      expect(User.count).to eq 0
      CreateAdminService.call
      expect(User.count).to eq 1
      expect(account.users.first.reload.super_admin?).to be true
      Apartment::Tenant.switch('public') do
        expect(account.accounts_users.first.reload.admin?).to be true
      end
    end
  end
end
