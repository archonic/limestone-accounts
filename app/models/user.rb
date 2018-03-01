class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :accounts_users, autosave: true, dependent: :destroy
  has_many :accounts, through: :accounts_users
  has_many :invoices
  has_one_attached :avatar

  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :set_full_name

  scope :super_admins, -> { where(super_admin: true) }

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def accounts_user
    self.accounts_users.where(account: current_account).limit(1).first
  end

  # Allows features to be flipped for individuals
  def flipper_id
    "User;#{id}"
  end

  private

  def set_full_name
    self.full_name = [first_name, last_name].join(' ').strip
  end
end
