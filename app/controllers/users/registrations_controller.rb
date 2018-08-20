# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def edit
      authorize current_user
      super
    end

    def update
      authorize current_user
      super
    end

    protected

      def after_update_path_for(_resource)
        edit_user_registration_path
      end
  end
end
