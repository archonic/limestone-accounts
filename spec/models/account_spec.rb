require 'rails_helper'

RSpec.describe Account, type: :model do
  it 'has a valid factory' do
    expect(create(:account)).to be_valid
  end

  # Validations
  it { is_expected.to_not allow_value("1").for(:name) }
  it { is_expected.to_not allow_value("averyveryveryveryveryveryveryveryverylongname").for(:name) }
  it { is_expected.to_not allow_value("1").for(:subdomain) }
  it { is_expected.to_not allow_value("averyveryveryveryveryveryveryveryverylongname").for(:subdomain) }
  it { is_expected.to_not allow_value("omg!").for(:subdomain) }
  it { is_expected.to_not allow_value("has space").for(:subdomain) }
  it { is_expected.to_not allow_value("[hai]").for(:subdomain) }
  it { is_expected.to allow_value("subdomain1").for(:subdomain) }

  # Callbacks
  describe '#create_tenant' do
    it 'creates the tenant' do
      # allow(Apartment::Tenant).to receive(:create).and_return true
      expect(Apartment::Tenant).to receive(:create).once.with( 'first' )
      create(:account, subdomain: 'first')
    end
  end

  # Methods
  describe '#subscribed?' do
    it 'returns false for no card' do
      expect(build(:account, card_last4: nil).subscribed?).to be false
    end

    it 'returns true for card present' do
      expect(build(:account, card_last4: '1234').subscribed?).to be true
    end
  end

  describe '#trial_expired?' do
    def trial_expired?
      trialing? &&
      current_period_end < Time.current
    end

    it 'returns true for expired trial' do
      expect(
        build(:account,
          trialing: true,
          current_period_end: 1.hour.ago
        ).trial_expired?
      ).to be true
    end

    it 'returns false for valid trial' do
      expect(
        build(:account,
          trialing: true,
          current_period_end: 1.hour.from_now
        ).trial_expired?
      ).to be false
    end

    it 'returns false for not trialing' do
      expect(
        build(:account,
          trialing: false,
          current_period_end: 1.hour.from_now
        ).trial_expired?
      ).to be false
    end
  end

  describe '#active? and #inactive?' do
    it 'returns false cancelled' do
      expect(
        build(:account, cancelled: true, unpaid: false).active?
      ).to be false
    end

    it 'returns false for unpaid' do
      expect(
        build(:account, cancelled: false, unpaid: true).active?
      ).to be false
    end

    it 'returns true not cancelled or expired' do
      expect(
        build(:account, cancelled: false, unpaid: false).active?
      ).to be true
    end
  end

  describe '#flipper_id' do
    it 'returns namespaced id' do
      expect(create(:account).flipper_id).to match /Account;/
    end
  end
end
