class AccountPolicy < ApplicationPolicy
  def show?
    accounts_user.public_has_role? :admin
  end

  def create?
    true
  end

  def update?
    accounts_user.public_has_role? :admin
  end

  def destroy?
    update?
  end
end
