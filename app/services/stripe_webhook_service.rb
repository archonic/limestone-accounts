# Manages all incoming stripe webhooks
class StripeWebhookService
  def no_account_error(klass, account_stripe_customer_id)
    StripeLogger.error "#{klass.class.name.upcase} ERROR: No account found with stripe_customer_id #{account_stripe_customer_id}."
    yield
  end

  def assign_plan(account_attributes, stripe_plan)
    plan = Plan.find_by( stripe_id: stripe_plan.id )
    if plan.present?
      account_attributes[:plan_id] = plan.id
    else
      StripeLogger.error "ASSIGN_PLAN ERROR: No local plan found for #{stripe_plan.id}"
    end
  end

  def process_subscription_status(subscription, account_attributes)
    case subscription.status
    when 'trialing'
      account_attributes[:trialing] = true
    when 'active'
      # Ensure unpaid/past_due/cancelled accounts resubscribing have right statuses
      account_attributes[:trialing]  = false
      account_attributes[:past_due]  = false
      account_attributes[:unpaid]    = false
      account_attributes[:cancelled] = false
    when 'past_due'
      account_attributes[:past_due] = true
    when 'cancelled'
      account_attributes[:cancelled] = true
    when 'unpaid'
      account_attributes[:unpaid] = true
    else
      StripeLogger.error "#{self.class.name} ERROR: Unknown subscription status #{subscription.status}."
    end
    assign_plan(account_attributes, subscription.plan)
  end

  class RecordInvoicePaid < StripeWebhookService
    def call(event)
      event_data = event.data.object
      account = Account.find_by(stripe_customer_id: event_data.customer)
      no_account_error(self, event_data.customer) { return } if account.nil?

      # Ignore invoices for $0.00 such as trial period invoice
      return true if event_data.total.zero?

      invoice = account.invoices.where(stripe_id: event_data.id).first_or_initialize
      lines = event_data.lines.data
      invoice.assign_attributes(
        amount: event_data.total,
        currency: event_data.currency,
        number: event_data.number,
        paid_at: Time.at(event_data.date).to_datetime,
        lines: lines
      )
      invoice.save
      UserMailer.invoice_paid(account.owner.user, invoice).deliver_later
      return true
    end
  end

  class UpdateCustomer < StripeWebhookService
    def call(event)
      event_data = event.data.object
      account = Account.find_by(stripe_customer_id: event_data.id)
      no_account_error(self, event_data.id) { return } if account.nil?
      # Hold all attributes until assignment. Makes it easier to test.
      account_attributes = {}

      # Update card info
      # Each customer should have just one source. Log if that's not the case.
      sources = event_data.sources
      if sources.present?
        if sources.total_count > 1
          StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has #{sources.total_count} sources. There's supposed to have one!"
        elsif sources.total_count == 1
          source = sources.first
          account_attributes[:card_last4] = source.last4
          account_attributes[:card_type] = source.brand
          account_attributes[:card_exp_month] = source.exp_month
          account_attributes[:card_exp_year] = source.exp_year
        end
      else
        StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has no source."
      end

      # Update role based on subscription status and current_period_end
      # Each customer should have just one subscription. Log if that's not the case.
      subscriptions = event_data.subscriptions
      if subscriptions.present?
        if subscriptions.total_count > 1
          StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has #{subscriptions.total_count} subscriptions. They're supposed to have one!"
        elsif subscriptions.total_count == 1
          subscription = subscriptions.first
          process_subscription_status(subscription, account_attributes)
          account_attributes[:current_period_end] = Time.at(subscription.current_period_end).to_datetime
        end
      else
        StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has no subscription."
      end
      account.update account_attributes
      # This event is fired on new trials. Only send email if the source is present.
      UserMailer.billing_updated(account.owner.user).deliver_later if sources.try(:total_count) == 1
      return true
    end
  end

  # Fires when switching plans
  class UpdateSubscription < StripeWebhookService
    def call(event)
      subscription = event.data.object
      account = Account.find_by(stripe_customer_id: subscription.customer)
      no_account_error(self, subscription.customer) { return } if account.nil?
      account_attributes = {}
      process_subscription_status(subscription, account_attributes)
      account_attributes[:current_period_end] = Time.at(subscription.current_period_end).to_datetime
      account.update(account_attributes)
    end
  end

  class TrialWillEnd < StripeWebhookService
    def call(event)
      event_data = event.data.object
      account = Account.find_by(stripe_customer_id: event_data.customer)
      no_account_error(self, event_data.customer) { return } if account.nil?
      UserMailer.trial_will_end(account.owner.user).deliver_later
      return true
    end
  end

  class SourceExpiring < StripeWebhookService
    def call(event)
      card = event.data.object
      account = Account.find_by(stripe_customer_id: card.customer)
      no_account_error(self, card.customer) { return } if account.nil?
      UserMailer.source_expiring(account.owner.user, card).deliver_later
      return true
    end
  end

  class Dun < StripeWebhookService
    def call(event)
      event_data = event.data.object
      account = Account.find_by(stripe_customer_id: event_data.customer)
      no_account_error(self, event_data.customer) { return } if account.nil?
      UserMailer.invoice_failed(
        account.owner.user,
        event_data.attempt_count,
        event_data.next_payment_attempt.to_i
      ).deliver_later
      return true
    end
  end
end
