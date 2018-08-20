# frozen_string_literal: true

class CreateAdminService
  def self.call
    admin_user = User.find_or_create_by!(
      email: ENV["ADMIN_EMAIL"]
    ) do |u|
      u.password = ENV["ADMIN_PASSWORD"]
      u.password_confirmation = ENV["ADMIN_PASSWORD"]
      u.first_name = ENV["ADMIN_FIRST_NAME"]
      u.last_name = ENV["ADMIN_LAST_NAME"]
      u.super_admin = true
    end
    account = Account.find_by(subdomain: "limestone")
    admin_au = AccountsUser.find_or_create_by!(
      user_id: admin_user.id,
      account_id: account.id
    )
    Apartment::Tenant.switch("public") do
      admin_au.update role: "admin"
    end
    admin_user
  end
end
