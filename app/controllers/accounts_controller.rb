# frozen_string_literal: true

class AccountsController < ApplicationController
  include ActionView::Helpers::DateHelper
  before_action :skip_authorization, only: %i(new create)
  before_action :check_public_registration, only: %i(new create)
  before_action :set_account, only: %i(show edit destroy)
  before_action :setup_form, only: %i(new create)

  def show
    authorize @account
    @members = @account.accounts_users.order(:id)
  end

  def new
    @account = Account.new
    @account.build_owner_au.user = User.new
  end

  def edit
    authorize @account
  end

  def create
    @account = Account.new(account_create_params)
    if @account.save
      account_create_actions
      redirect_to new_user_session_url( subdomain: @account.subdomain )
    else
      render :new
    end
  end

  def destroy
    authorize @account
    # Can't look up the subscription on Stripe if we don't have it.
    # If stripe_subscription_id is nil, subscription was either never setup or already destroyed
    return true if @account.stripe_subscription_id.nil?
    SubscriptionService.new(
      @account
    ).destroy_subscription
    @account.discard
  end

  private

    def set_account
      @account = current_account
    end

    def account_create_actions
      UserMailer.welcome_email(@account.owner_au.user, @account).deliver_later
      # Must use owner_au here to add role correctly
      Apartment::Tenant.switch('public') do
        @account.owner_au.role = "admin"
        @account.owner_au.user.invitation_accepted_at = Time.current
      end
      SubscriptionService.new(
        @account,
        plan_id: @account.plan_id
      ).create_subscription
    end

    def setup_form
      @plans = Plan.active.order(:amount)
      @minimum_password_length = Devise.password_length.min
    end

    def account_create_params
      params.require(:account).permit(
        :plan_id,
        :name,
        :subdomain,
        owner_au_attributes: {
          user_attributes: %i(
            email
            first_name
            last_name
            password
          )
        }
      )
    end

    def check_public_registration
      redirect_to root_path, flash: { warning: 'That feature is not enabled.' } unless Flipper.enabled?(:public_registration)
    end
end
