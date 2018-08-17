# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def dropdown?
    true
  end

  def create?
    false
  end

  def update?
    recipient == user
  end

  def destroy?
    false
  end

  def read?
    record.recipient == user
  end

  class Scope < Scope
    def resolve
      user.notifications_received.order(created_at: :desc)
    end
  end
end
