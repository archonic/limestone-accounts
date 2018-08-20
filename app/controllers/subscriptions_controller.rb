# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  skip_before_action :check_access, only: :show

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.
  # We use the columns on the account to know an account's subscription status.

  def show
    redirect_to subscribe_path unless @account.subscribed?
    authorize :subscription
    @plans = Plan.active
  end

  def new
    authorize :subscription
    redirect_to billing_path if @account.subscribed?
  end

  def update
    authorize :subscription
    if @account.stripe_subscription_id.present? &&
       SubscriptionService.new(@account, params).update_subscription
      redirect_to billing_path, flash: { success: "Subscription updated! If this change alters your abilities, please allow a moment for us to update them." }
    else
      redirect_to subscribe_path, flash: { error: "There was an error updating your subscription." }
    end
  end

  private

    def set_account
      @account = current_account
    end
end
