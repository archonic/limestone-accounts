# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :request do
  let(:au) { create(:accounts_user) }
  let(:account) { au.account }
  let(:user) { au.user }

  before do
    host! "#{account.subdomain}.lvh.me:3000"
  end

  describe "#update" do
    subject do
      patch user_registration_path(user), params: {
        user: {
          first_name: "#{user.first_name} updated",
          current_password: "password"
        }
      }
      response
    end

    context "logged in" do
      before { sign_in user }
      it "updates the user" do
        name_old = user.first_name
        subject
        expect(user.reload.first_name).to eq "#{name_old} updated"
      end
    end

    context "logged out" do
      it "says they need to log in" do
        expect(subject).to have_http_status(:redirect)
        expect(flash[:alert]).to match /You need to sign in or sign up before continuing/
      end
    end
  end

  describe "#edit" do
    subject do
      get edit_user_registration_path
      response
    end

    context "logged in" do
      before { sign_in user }
      it "serves edit page" do
        expect(subject).to have_http_status(:success)
        expect(flash.any?).to be false
      end
    end

    context "logged out" do
      it "says they need to log in" do
        expect(subject).to have_http_status(:redirect)
        expect(flash[:alert]).to match /You need to sign in or sign up before continuing/
      end
    end
  end
end
