class Users::SessionsController < Devise::SessionsController
  before_action :skip_authorization, only: [:new, :create, :destroy, :find_workspace]

  def create
    user_to_sign_in = User.find_by(email: params[:user][:email])
    if user_to_sign_in.try(:accounts_user, current_account).try(:discarded?)
      flash[:error] = 'You have been removed from this account.'
      redirect_to new_user_session_path
    else
      super
    end
  end

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
