class ApplicationController < ActionController::Base
  include Pundit
  include ActionView::Helpers::DateHelper
  include ApartmentHelper
  protect_from_forgery with: :exception
  impersonates :user
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_access, if: :access_required?

  # Pundit reminder to call authorize within actions or scope for index actions
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def after_sign_in_path_for(resource)
    # If subdomain isn't provided, go to users first account
    account = if request.subdomains.try(:first).nil?
      resource.accounts.order(:id).first
    else
      current_account
    end
    dashboard_url(subdomain: account.subdomain)
  end

  # Users hitting this method are accepting their first invitation
  # So we can assume they want to sign into their first/only account
  # NOTE not currently hit
  # def after_accept_path_for(resource)
  #   subdomain = resource.accounts.first.try(:subdomain)
  #   new_user_session_path(subdomain: account.subdomain)
  # end

  # Replaces 'current_user' to provide account and accounts_user in Context.
  def pundit_user
    @pundit_user ||= Context.new(
      account: current_account,
      accounts_user: current_accounts_user,
      user: current_user
    )
  end

  protected

  def configure_permitted_parameters
    added_params = [:first_name, :last_name, :avatar, :plan_id]
    devise_parameter_sanitizer.permit :sign_up, keys: added_params
    devise_parameter_sanitizer.permit :account_update, keys: added_params
    devise_parameter_sanitizer.permit :accept_invitation, keys: [:first_name, :last_name]
  end

  # Users are always allowed to manage their session, registration, subscription and account
  def access_required?
    user_signed_in? &&
    !devise_controller? &&
    !%w(
      subscriptions
      accounts
    ).include?(controller_name)
  end

  # Redirect users in accounts in bad standing to billing page
  def check_access
    if current_account && current_account.inactive?
      redirect_to billing_path, flash: { error: 'Your account is inactive. Access will be restored once payment succeeds.' }
    end
  end
end
