# frozen_string_literal: true

class InvitationPolicy < ApplicationPolicy
  def create?
    accounts_user.admin?
  end
end
