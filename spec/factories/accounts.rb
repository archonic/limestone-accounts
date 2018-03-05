FactoryBot.define do
  factory :account do
    name { Faker::StarTrek.location }
    subdomain { name.downcase.parameterize }
    association :plan
    trialing true
    past_due false
    unpaid false
    cancelled false
    current_period_end 14.days.from_now

    initialize_with { Account.where(subdomain: subdomain).first_or_initialize }

    trait :subscribed do
      trialing false
      # default customer and subscription ids from ruby_stripe_mock (mocks not fixtures)
      stripe_customer_id 'test_cus_1'
      stripe_subscription_id 'test_su_2'
      card_last4 '1234'
      card_type 'Visa'
      card_exp_month '02'
      card_exp_year '2025'
      current_period_end 31.days.from_now
    end
  end
end
