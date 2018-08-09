class AccountsUserPolicy < ApplicationPolicy
  def destroy?
    accounts_user.owner? &&
      !record.owner?
  end
end
