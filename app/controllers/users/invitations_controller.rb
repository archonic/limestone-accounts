class Users::InvitationsController < Devise::InvitationsController
  # Invitations Controller has it's own token based authentication
  before_action :skip_authorization, only: [:edit, :update]

  def new
    authorize :invitation
    super
  end

  def create
    authorize :invitation
    emails = params[:user][:email].split(',').map(&:strip)
    results = UserInvitationService.mass_invite!(current_account, emails, current_user)
    users_failed = results[:users_failed]
    success_count = results[:users_successful].size
    success_msg = "#{success_count} #{'member'.pluralize(success_count)} successfully invited."
    flash[:success] = success_msg unless success_count.zero?
    if users_failed.any?
      failure_count = users_failed.size
      failure_msg = "#{failure_count} #{'member'.pluralize(failure_count)} failed to be invited."
      flash.merge!( error: failure_msg, emails_failed: users_failed )
    end
    redirect_to account_show_path
  end

  def edit
    @minimum_password_length = Devise.password_length.min
    super
  end

  def update
    super
  end

  private
    # this is called when creating invitation
    # should return an instance of resource class
    # def invite_resource
    #   ## skip sending emails on invite
    #   super do |u|
    #     u.skip_invitation = true
    #   end
    # end

    # this is called when accepting invitation
    # should return an instance of resource class
    # def accept_resource
    #   resource = resource_class.accept_invitation!(update_resource_params)
    #   ## Report accepting invitation to analytics
    #   Analytics.report('invite.accept', resource.id)
    #   resource
    # end
end
