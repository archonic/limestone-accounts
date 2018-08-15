# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_notification, only: %i(read)

  def index
    authorize :notification
    unread = if index_params[:type].nil?
      true
    else
      index_params[:type] == "unread" ? true : false
    end
    @notifications = unread ? policy_scope(Notification).unread : policy_scope(Notification)
  end

  def dropdown
    authorize :notification
    @notifications =  current_user
                      .notifications_received
                      .unread
                      .limit(8)
                      .order("notifications.created_at DESC")
    render "dropdown", layout: false
  end

  def read
    authorize @notification
    @notification.update(read: true)
  end

  private

    def set_notification
      @notification = Notification.find(params[:id])
    end

    def index_params
      params.permit(:type)
    end

    def notification_params
      params.require(:notification).permit(
        :read
      )
    end

end
