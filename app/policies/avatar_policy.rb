# frozen_string_literal: true

# def pay_for_3d?; false; end
class AvatarPolicy < ApplicationPolicy
  def update?
    record.record == user
  end

  def destroy?
    update?
  end
end
