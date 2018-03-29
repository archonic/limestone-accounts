class AccountsUser < ApplicationRecord
  include Discard::Model
  rolify strict: true
  # Would prefer to not have optional: true but seems to be
  # required for validation despite accepts_nested_attributes_for
  # https://github.com/rails/rails/issues/25198#issuecomment-372894070
  belongs_to :account, inverse_of: :accounts_users, optional: true
  belongs_to :user, autosave: true, inverse_of: :accounts_users

  accepts_nested_attributes_for :user

  validates :user, uniqueness: {
    scope: :account_id,
    message: 'User already exists in this account.'
  }

  scope :admins, -> { Apartment::Tenant.switch('public') { AccountsUser.with_role(:admin) } }

  delegate :email, to: :user
  delegate :full_name, to: :user
  delegate :avatar, to: :user

  def owner?
    Apartment::Tenant.switch('public') { account.owner_au == self }
  end

  def public_has_role?(role)
    Apartment::Tenant.switch('public') do
      self.has_role? role
    end
  end
end
