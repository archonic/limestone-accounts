# frozen_string_literal: true

FactoryBot.define do
  factory :accounts_user do
    association :account
    association :user

    trait :admin do
      role "admin"
    end
    trait :user do
      role "user"
    end

    trait :subscribed do
      association :account, :subscribed
    end
  end
end
