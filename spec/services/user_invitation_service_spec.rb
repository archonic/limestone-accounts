require 'rails_helper'

RSpec.describe UserInvitationService, type: :service do
  let(:account) { create(:account) }
  let(:good_emails) do
    result = []
    5.times do
      result << Faker::Internet.email
    end
    result
  end
  let(:bad_emails) { Faker::Company.bs.downcase.split(' ') }
  let(:good_and_bad_emails) { good_emails + bad_emails }

  describe 'mass_invite!' do
    context 'with only bad emails' do
      it 'has failures and no successes' do
        results = UserInvitationService.mass_invite!(account, bad_emails)
        expect(results[:users_successful].size).to eq 0
        expect(results[:users_failed]).to eq bad_emails
      end
    end

    context 'with both good and bad emails' do
      it 'populates both successful and failed results' do
        results = UserInvitationService.mass_invite!(account, good_and_bad_emails)
        expect(results[:users_successful].size).to eq 5
        expect(results[:users_failed]).to eq bad_emails
      end
    end

    context 'with only good emails' do
      it 'has successes and no failures' do
        results = UserInvitationService.mass_invite!(account, good_emails)
        expect(results[:users_failed]).to be_empty
        expect(results[:users_successful].size).to eq 5
      end

      it 'creates 5 users' do
        expect(User.count).to eq 0
        UserInvitationService.mass_invite!(account, good_emails)
        expect(User.count).to eq 5
      end

      it 'calls invite!' do
        # Counting messages doesn't seem to work with expect_any_instance_of
        expect_any_instance_of(User).to receive(:invite!).once
        UserInvitationService.mass_invite!(account, [good_emails.first])
      end

      context 'inviting existing user to different account' do
        let(:account_second) { create(:account, subdomain: 'second') }
        let(:au) { create(:accounts_user, account: account) }
        let(:user) { au.user }

        it 'sends invite_to_account' do
          invite_to_account_dbl = double(ActionMailer::MessageDelivery)
          allow(UserMailer).to receive(:invite_to_account).and_return(invite_to_account_dbl)
          results = UserInvitationService.mass_invite!(account_second, [user.email])
          expect(results[:users_successful].first).to eq user
        end
      end
    end
  end
end
