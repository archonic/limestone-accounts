class Account < ActiveRecord::Base
  include Discard::Model

  has_many :accounts_users, inverse_of: :account
  has_many :users, through: :accounts_users
  has_one :owner_au, -> {
    where(role: "admin").order(:id)
  }, class_name: 'AccountsUser', inverse_of: :account
  has_many :invoices
  # set optional: true if you don't want the default Rails 5 belongs_to presence validation
  belongs_to :plan

  validates :name,
    length: { in: 2..40 }

  validates :subdomain,
    length: { in: 2..40 },
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9\-]+\Z/i, message: 'accepts only letters, numbers and a dash.' },
    if: :subdomain_changed?

  delegate :cost, to: :plan, prefix: true
  delegate :amount, to: :plan, prefix: true
  delegate :currency, to: :plan, prefix: true
  delegate :name, to: :plan, prefix: true
  delegate :user, to: :owner_au, prefix: true

  accepts_nested_attributes_for :owner_au

  before_create :set_current_period_end
  after_create :create_tenant

  def owner
    Apartment::Tenant.switch('public') { self.owner_au }
  end

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

  def active_users
    accounts_users.joins(:user).kept.where.not(users: { invitation_accepted_at: nil })
  end

  private

    def create_tenant
      Apartment::Tenant.create(subdomain)
    end

    def set_current_period_end
      self.current_period_end = Time.now + $trial_period_days.days
    end
end
