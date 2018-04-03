require 'rails_helper'

RSpec.describe UserInvitationService, type: :service do
  let!(:au) { create(:accounts_user) }
  let(:account) { au.account }
  let(:user) { au.user }
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
        results = UserInvitationService.mass_invite!(account, bad_emails, user)
        expect(results[:users_successful].size).to eq 0
        expect(results[:users_failed]).to eq bad_emails
      end
    end

    context 'with both good and bad emails' do
      it 'populates both successful and failed results' do
        results = UserInvitationService.mass_invite!(account, good_and_bad_emails, user)
        expect(results[:users_successful].size).to eq 5
        expect(results[:users_failed]).to eq bad_emails
      end
    end

    context 'with only good emails' do
      subject do
        UserInvitationService.mass_invite!(account, good_emails, user)
      end

      it 'has successes and no failures' do
        expect(subject[:users_failed]).to be_empty
        expect(subject[:users_successful].size).to eq 5
      end

      it 'creates 5 users' do
        expect(User.count).to eq 1
        subject
        expect(User.count).to eq 6
      end

      it 'populates invited_by and invited_account_id' do
        subject
        invited_user = User.find_by(email: subject[:users_successful].first.email)
        expect(invited_user.invited_by).to eq user
        expect(invited_user.invited_account_id).to eq account.id
      end

      it 'calls invite!' do
        # Counting messages doesn't seem to work with expect_any_instance_of
        expect_any_instance_of(User).to receive(:invite!).once
        UserInvitationService.mass_invite!(account, [good_emails.first], user)
      end

      context 'inviting existing user to different account' do
        let(:account_second) { create(:account, subdomain: 'second') }

        it 'sends invite_to_account' do
          binding.pry
          invite_to_account_dbl = double(ActionMailer::MessageDelivery)
          allow(UserMailer).to receive(:invite_to_account).and_return(invite_to_account_dbl)
          results = UserInvitationService.mass_invite!(account_second, [user.email], user)
          expect(results[:users_successful].first).to eq user
        end
      end
    end
  end
end
