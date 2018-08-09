class AccountPolicy < ApplicationPolicy
  def show?
    accounts_user.admin?
  end

  def create?
    true
  end

  def update?
    accounts_user.admin?
  end

  def destroy?
    update?
  end
end
