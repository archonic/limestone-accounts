# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Administrate Dashboards", type: :request do
  let(:super_admin) { create(:user, :super_admin) }
  let(:user) { create(:user) }

  context "as super admin" do
    before { sign_in super_admin }

    describe UserDashboard do
      subject do
        get admin_users_path
        response
      end

      it "allows admins to access /admin" do
        expect(subject).to have_http_status(:success)
      end

      describe "impersonate" do
        it "allows impersonation of users" do
          post impersonate_admin_user_path(user.id)
          expect(response).to have_http_status(:redirect)
          expect(flash.any?).to eq false
        end
      end

      describe "stop_impersonating" do
        it "allows stop impersonating" do
          get admin_stop_impersonating_path
          expect(response).to have_http_status(:redirect)
          expect(flash.any?).to eq false
        end
      end
    end

    describe InvoiceDashboard do
      subject do
        get admin_invoices_path
        response
      end

      it "allows admins to access /admin/invoices" do
        expect(subject).to have_http_status(:success)
      end
    end

    describe AccountDashboard do
      subject do
        get admin_accounts_path
        response
      end

      it "allows super admins to access /admin" do
        expect(subject).to have_http_status(:success)
      end
    end

    describe PlanDashboard do
      subject do
        get admin_plans_path
        response
      end

      it "allows super admins to access /admin/plans" do
        expect(subject).to have_http_status(:success)
      end
    end
  end

  context "as user" do
    before { sign_in user }

    describe UserDashboard do
      it "raises no route matches" do
        expect{ get admin_users_path }.to raise_error(ActionController::RoutingError)
      end
    end

    describe InvoiceDashboard do
      it "raises no route matches" do
        expect{ get admin_invoices_path }.to raise_error(ActionController::RoutingError)
      end
    end

    describe AccountDashboard do
      it "allows super admins to access /admin" do
        expect{ get admin_accounts_path }.to raise_error(ActionController::RoutingError)
      end
    end

    describe PlanDashboard do
      it "allows super admins to access /admin" do
        expect{ get admin_plans_path }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
