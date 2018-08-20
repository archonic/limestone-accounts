# frozen_string_literal: true

class PagesController < ApplicationController
  # You may want to manage your static pages with something like HubSpot,
  # or serve static pages with a nginx / apache / whatever directly
  before_action :skip_authorization
end
