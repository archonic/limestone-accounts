FactoryBot.define do
  factory :accounts_user do
    association :account
    association :user

    trait :subscribed  do
      association :account, :subscribed
    end
  end
end
