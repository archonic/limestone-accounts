FactoryBot.define do
  factory :notification do
    association :sender, factory: :user
    association :recipient, factory: :user
    action "example"
    association :notifiable, factory: :user
    target_name_cached "Example notification"
    target_path_params {}
    read false
  end
end
