require 'stripe_mock'

FactoryBot.define do
  factory :plan do
    name 'World Domination'
    amount 100000
    interval 'month'
    currency 'usd'
    stripe_id 'example-plan-id'
    initialize_with { Plan.where(name: name).first_or_initialize }
  end
end
