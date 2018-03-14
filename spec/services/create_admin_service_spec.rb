require 'rails_helper'
require 'stripe_mock'

RSpec.describe CreateAdminService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#call' do
    before do
      create(:plan)
      create(:account, subdomain: 'limestone')
    end

    it 'creates the admin' do
      expect(User.count).to eq 0
      CreateAdminService.call
      expect(User.count).to eq 1
      expect(User.first.reload.super_admin?).to be true
      Apartment::Tenant.switch('limestone') do
        expect(User.first.accounts_users.first.reload.has_role?(:admin)).to be true
      end

    end
  end
end
