# frozen_string_literal: true

class Context
  attr_reader :account, :accounts_user, :user

  def initialize(account: nil, accounts_user: nil, user: nil)
    @account = account
    @accounts_user = accounts_user
    @user = user
  end

  def accounts_user_associated?
    if accounts_user.account_id == account.id &&
       accounts_user.user_id == user.id
      true
    else
      false
    end
  end
end
