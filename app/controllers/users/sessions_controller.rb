class Users::SessionsController < Devise::SessionsController
  def find_workspace
    subdomain = Account.find_by(subdomain: params[:subdomain]).try(:subdomain)
    if subdomain
      redirect_to new_user_session_url(subdomain: subdomain)
    else
      flash[:error] = 'That workspace was not found.'
      render :new
    end
  end
end
