class SubscriptionPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    create?
  end

  def show?
    true
  end
end
