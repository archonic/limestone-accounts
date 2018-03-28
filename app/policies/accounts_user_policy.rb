class AccountPolicy < ApplicationPolicy
  def destroy?
    @current_accounts_user.owner?
  end
end
