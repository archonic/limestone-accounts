class InvitationPolicy < ApplicationPolicy
  def create?
    accounts_user.public_has_role? :admin
  end
end
