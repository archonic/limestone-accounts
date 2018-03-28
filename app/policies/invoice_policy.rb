class InvoicePolicy < ApplicationPolicy
  def show?
    record.account == account
  end

  # class Scope < Scope
  #   def resolve
  #     scope.where(account_id: account.id)
  #   end
  # end
end
