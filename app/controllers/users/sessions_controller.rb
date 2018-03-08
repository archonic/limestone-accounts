class Users::SessionsController < Devise::SessionsController

  def find_workspace
    subdomain = Account.find_by(subdomain: params[:subdomain]).try(:subdomain)
    if subdomain
      redirect_to new_user_session_url(subdomain: subdomain)
    else
      redirect_to new_user_session_path, flash: { error: 'That workspace was not found.' }
    end
  end
end
