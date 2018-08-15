# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def index?
    true
  end

  def all_notifications?
    index?
  end

  def dropdown?
    index?
  end

  def show?
    record.recipient == user
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
