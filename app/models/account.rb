class Account < ActiveRecord::Base
  has_many :accounts_users
  has_many :users, through: :accounts_users
  has_one :owner, -> { AccountsUser.admins.order(:id) }, class_name: 'AccountsUser'
  # set optional: true if you don't want the default Rails 5 belongs_to presence validation
  belongs_to :plan

  delegate :cost, to: :plan
  delegate :name, to: :plan, prefix: true

  accepts_nested_attributes_for :owner

  after_create :create_tenant

  # Only checks that they have a source, not that they're in good standing
  def subscribed?
    card_last4.present?
  end

  def trial_expired?
    trialing? &&
    current_period_end < Time.current
  end

  # true if account is in good standing
  def accessible?
    !cancelled || !unpaid
  end

  private

    def create_tenant
      Apartment::Tenant.create(subdomain)
    end
end
