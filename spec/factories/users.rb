# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email {  Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    invitation_accepted_at Time.current # Users who signed up for the account get this assigned in AccountsUsersController#create
    initialize_with { User.where(email: email).first_or_initialize }

    trait :super_admin do
      super_admin true
    end

    trait :invited do
      password nil
      password_confirmation nil
      invitation_created_at Time.now.utc
      invitation_sent_at Time.now.utc
      invitation_accepted_at nil
    end
  end
end
