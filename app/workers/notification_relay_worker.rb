# frozen_string_literal: true

class NotificationRelayWorker
  include Sidekiq::Worker
  sidekiq_options queue: "#{ENV['ACTIVE_JOB_QUEUE_PREFIX']}_#{Rails.env}_default"

  def perform(notification_id, action)
    notification = Notification.find(notification_id)
    html = ApplicationController.render(
      partial: "notifications/notification_dropdown_item",
      locals: {
        notification: notification
      },
      formats: [:html]
    )
    ActionCable.server.broadcast "notifications:#{notification.recipient_id}", id: notification_id, action: action, html: html
  end
end
