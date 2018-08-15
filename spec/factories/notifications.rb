FactoryBot.define do
  factory :notification do
    sender_id 1
    recipient_id 1
    action "MyString"
    notifiable nil
    target_name_cached "MyString"
    target_path_params ""
    read false
  end
end
