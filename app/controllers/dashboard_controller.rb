class DashboardController < ApplicationController
  def show
    authorize :dashboard
  end
end
