require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    subdomain: Field::String,
    plan: Field::BelongsTo,
    stripe_customer_id: Field::String,
    stripe_subscription_id: Field::String,
    card_last4: Field::String,
    card_exp_month: Field::String,
    card_exp_year: Field::String,
    card_type: Field::String,
    current_period_end: Field::DateTime,
    trialing: Field::Boolean,
    past_due: Field::Boolean,
    unpaid: Field::Boolean,
    cancelled: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :subdomain,
    :plan,
    :current_period_end,
    :trialing,
    :past_due,
    :unpaid,
    :cancelled
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :subdomain,
    :plan,
    :stripe_customer_id,
    :stripe_subscription_id,
    :card_last4,
    :card_exp_month,
    :card_exp_year,
    :current_period_end,
    :trialing,
    :past_due,
    :unpaid,
    :cancelled
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :subdomain,
    :plan,
    :current_period_end,
    :trialing,
    :past_due,
    :unpaid,
    :cancelled
  ].freeze

  # Overwrite this method to customize how accounts are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(account)
    'Account ' + account.name
  end
end
