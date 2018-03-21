class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :accounts_users, autosave: true, dependent: :destroy, inverse_of: :user
  has_many :accounts, through: :accounts_users

  has_one_attached :avatar

  accepts_nested_attributes_for :accounts_users, reject_if: :all_blank

  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, presence: true, length: { in: Devise.password_length }, if: :password_required?
  validates :first_name, presence: true, unless: :being_invited?
  validates :last_name, presence: true, unless: :being_invited?

  before_save :set_full_name

  scope :super_admins, -> { where(super_admin: true) }

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def accounts_user(account)
    self.accounts_users.find_by(account: account)
  end

  # Allows features to be flipped for individuals
  def flipper_id
    "User;#{id}"
  end

  def being_invited!
    @being_invited = true
  end

  def activated?
    invitation_accepted_at.present?
  end

  protected

    def password_required?
      (
        !persisted? ||
        !password.blank? ||
        !password_confirmation.blank?
      ) &&
      !being_invited?
    end

  private

    def set_full_name
      self.full_name = being_invited? ? 'Invited Member' : [first_name, last_name].join(' ').strip
    end

    def being_invited?
      !!@being_invited
    end
end
