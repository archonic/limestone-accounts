class InvitationPolicy < ApplicationPolicy
  def create?
    accounts_user.admin?
  end
end
