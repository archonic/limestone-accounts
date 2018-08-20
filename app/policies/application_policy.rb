# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :context, :record
  delegate :account, :accounts_user, :user, to: :context, allow_nil: true

  def initialize(context, record)
    raise ArgumentError, "Context argument is not an instance of Context" unless context.is_a? Context
    raise Pundit::NotAuthorizedError, "You must be signed in" unless context.try(:user)
    raise Pundit::NotAuthorizedError, "Account is missing" unless context.try(:account)
    raise Pundit::NotAuthorizedError, "Account is inactive (cancelled or unpaid)" if context.account.inactive?
    raise Pundit::NotAuthorizedError, "AccountUser is missing" unless context.try(:accounts_user)
    raise Pundit::NotAuthorizedError, "AccountUser is not associated with User and/or Account" unless context.accounts_user_associated?
    @context = context
    @record = record
  end

  # Whitelist by default
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :context, :scope
    delegate :account, :accounts_user, :user, to: :context, allow_nil: true

    def initialize(context, scope)
      raise ArgumentError "Context argument is not an instance of Context" unless context.is_a? Context
      raise Pundit::NotAuthorizedError, "You must be signed in" unless context.try(:user)
      raise Pundit::NotAuthorizedError, "Account is missing" unless context.try(:account)
      raise Pundit::NotAuthorizedError, "Account is inactive (cancelled or unpaid)" if context.account.inactive?
      raise Pundit::NotAuthorizedError, "AccountUser is missing" unless context.try(:accounts_user)
      raise Pundit::NotAuthorizedError, "AccountUser is not associated with User and/or Account" unless context.accounts_user_associated?
      @context = context
      @scope = scope
    end

    def resolve
      # NOTE You will for sure want to change this after building out your models / relationships
      scope.has_attribute?(:account_id) ? scope.where(account_id: account.id) : scope
    end
  end
end
