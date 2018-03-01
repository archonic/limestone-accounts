module ApartmentHelper
  def current_account
    @current_account ||= Account.find_by(
      subdomain: request.subdomains.first
    )
  end

  def current_accounts_user
    current_user.accounts_users.where(
      account: current_account
    ).limit(1).first
  end
end
