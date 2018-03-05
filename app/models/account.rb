class Account < ActiveRecord::Base
  has_many :accounts_users
  has_many :users, through: :accounts_users
  has_many :invoices
  has_one :owner, -> { AccountsUser.admins.order(:id) }, class_name: 'AccountsUser'
  # set optional: true if you don't want the default Rails 5 belongs_to presence validation
  belongs_to :plan

  validates :name,
    length: { in: 2..40 }

  validates :subdomain,
    length: { in: 2..40 },
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9\-]+\Z/i, message: 'accepts only letters, numbers and a dash.' },
    if: :subdomain_changed?

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

  def inactive?
    cancelled || unpaid
  end

  def active?
    !inactive?
  end

  def flipper_id
    "Account;#{id}"
  end

  private

    def create_tenant
      Apartment::Tenant.create(subdomain)
    end
end
