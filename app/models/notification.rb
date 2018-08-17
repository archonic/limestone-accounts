class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where read: false }
  scope :read, -> { where read: true }

  after_commit :trigger_notification_relay_worker, on: %i(create update)

  # Example:
  # docker-compose exec web rails c
  # Apartment::Tenant.switch! "limestone"
  # Notification.create( recipient: User.first, sender: User.first, notifiable: User.first, action: "example", target_name_cached: "Example notification", target_path_params: {} )

  def trigger_notification_relay_worker
    NotificationRelayWorker.perform_async(id, transaction_include_any_action?([:create]) ? "create" : "read")
  end

  def target
    path_params = target_path_params.try(:symbolize_keys).try(:merge, {read: true})
    case action
    when "example"
      # example_path(path_params)
      "#fill_out_target_in_notification.rb"
    end
  end
end
