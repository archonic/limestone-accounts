class AccountsUser < ApplicationRecord
  rolify strict: true
  # Would prefer to not have optional: true but seems to be
  # required for validation despite accepts_nested_attributes_for
  belongs_to :account, inverse_of: :accounts_users, optional: true
  belongs_to :user, autosave: true, inverse_of: :accounts_users

  accepts_nested_attributes_for :user

  validates :user, uniqueness: {
    scope: :account_id,
    message: 'User already exists in this account.'
  }

  scope :admins, -> { Apartment::Tenant.switch('public') { AccountsUser.with_role(:admin) } }

  delegate :email, to: :user
end
