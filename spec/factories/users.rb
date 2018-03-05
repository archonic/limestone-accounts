FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email {  Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    initialize_with { User.where(email: email).first_or_initialize }

    trait :super_admin do
      super_admin true
    end
  end
end
