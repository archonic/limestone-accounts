# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    authorize :dashboard
  end
end
