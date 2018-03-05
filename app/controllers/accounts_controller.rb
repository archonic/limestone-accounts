class AccountsController < ApplicationController
  before_action :set_account, only: [:edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.find_each
  end

  # GET /accounts/new
  def new
    @plans = Plan.active.order(:amount)
    @account = Account.new
    @account.build_au_owner.user = current_user
    @minimum_password_length = Devise.password_length.min
  end

  def create
  end

  # GET /accounts/:id/edit
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
      @account = Account.find(params[:id])
    end
end
