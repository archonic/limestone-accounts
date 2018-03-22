class UserInvitationService
  class << self
    def mass_invite!(account, emails, inviter)
      users_successful = []
      users_failed = []

      emails.each do |email|
        user = User.find_or_initialize_by(email: email)
        user.accounts_users.find_or_initialize_by(account_id: account.id)
        user.being_invited!

        if user.save
          users_successful << user
          if user.activated?
            UserMailer.invite_to_account(user, account).deliver_later
          else
            # current_user is the inviter
            user.invite! inviter
          end
        else
          users_failed << user.email
        end
      end
      { users_successful: users_successful, users_failed: users_failed }
    end
  end
end
