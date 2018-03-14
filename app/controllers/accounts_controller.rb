class AccountsController < ApplicationController
  include ActionView::Helpers::DateHelper
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :setup_form, only: [:new, :create]

  # GET /account
  def show
    @members = @account.users
  end

  # GET /accounts/new
  def new
    @account = Account.new
    @account.build_owner.user = User.new
  end

  def create
    @account = Account.new(account_create_params)
    if @account.valid?
      @account.save
      UserMailer.welcome_email(@account.owner.user).deliver_later
      @account.owner.add_role :admin
      time_left_in_trial = distance_of_time_in_words(Time.current, @account.current_period_end)

      # TODO Show a success message
      # This is hard because of how session domains work and how Devise handles `flash`
      redirect_to new_user_session_url( subdomain: @account.subdomain )
    else
      flash[:error] = 'Problem! Try again.'
      render :new
    end
  end

  # GET /account_settings
  def edit
  end

  # PATCH /accounts/:id
  def update
  end

  # DELETE /accounts/:id
  def destroy
    # nope nope nope
  end

  private

    def set_account
      @account = current_account
    end

    def setup_form
      @plans = Plan.active.order(:amount)
      @minimum_password_length = Devise.password_length.min
    end

    def account_create_params
      params.require(:account).permit(
        :plan_id,
        :name,
        :subdomain,
        {
          owner_attributes: {
            user_attributes: [
              :email,
              :first_name,
              :last_name,
              :password
            ]
          }
        }
      )
    end
end
