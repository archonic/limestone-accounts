class AccountsUser < ApplicationRecord
  rolify strict: true
  belongs_to :account
  belongs_to :user

  scope :admins, -> { AccountsUser.with_role :admin }

  delegate :email, to: :user
end
