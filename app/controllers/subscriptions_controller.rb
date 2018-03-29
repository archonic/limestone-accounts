class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :check_access, only: :show

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.
  # We use the columns on the account to know an accounts subscription status.

  # GET /billing
  def show
    @account = current_account
    redirect_to subscribe_path unless @account.subscribed?
    authorize :subscription
    @plans = Plan.active
  end

  # GET /subscribe
  def new
    authorize :subscription
    @account= current_account
    redirect_to billing_path if @account.subscribed?
  end

  # PATCH /subscriptions
  def update
    authorize :subscription
    if current_account.stripe_subscription_id.present? &&
       SubscriptionService.new(current_account, params).update_subscription
      redirect_to billing_path, flash: { success: 'Subscription updated! If this change alters your abilities, please allow a moment for us to update them.' }
    else
      redirect_to subscribe_path, flash: { error: 'There was an error updating your subscription :(' }
    end
  end
end
