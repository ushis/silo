require 'digest/sha1'
require 'securerandom'

# The User model provides access to the users data and several methods for
# manipulation.
#
# Database scheme:
#
# - *id*               integer
# - *current_list_id*  integer
# - *username*         string
# - *email*            string
# - *password_digest*  string
# - *login_hash*       string
# - *name*             string
# - *prename*          string
# - *locale*           string
# - *created_at*       datetime
#
# It uses _bcrypt-ruby_ for password encryption. It provides the two properties
# _password_ and _password_confirmation_. They are used the following way:
#
#   user.password = params[:password]
#   user.password_confirmation = params[:password_confirmation]
#   user.save
#
# If the two passwords are not equal, the _save_ call will fail.
class User < ActiveRecord::Base
  attr_accessor :password_old

  attr_accessible :email, :password, :password_confirmation, :password_old,
                  :name, :prename, :locale

  attr_accessible :username, :email, :password, :password_confirmation,
                  :name, :prename, :locale, as: :current_admin

  attr_accessible :username, :email, :password, :password_confirmation,
                  :name, :prename, :locale, :privilege_attributes, as: :admin

  has_secure_password

  discrete_values :locale, I18n.available_locales, default: I18n.default_locale,
                  i18n_scope: :languages

  validates :password,   presence: true,  on: :create
  validates :username,   presence: true,  uniqueness: true, format: /\A[a-z0-9]+\z/
  validates :email,      presence: true,  uniqueness: true
  validates :login_hash, allow_nil: true, uniqueness: true
  validates :name,       presence: true
  validates :prename,    presence: true

  validates_with OldPasswordValidator, if: :check_old_password_before_save?

  has_many :experts
  has_many :partners
  has_many :lists

  has_one  :privilege, autosave: true, dependent: :destroy

  belongs_to :current_list, class_name: :List

  delegate :access?, :admin?, to: :privilege

  accepts_nested_attributes_for :privilege

  # Auto initializes the users privileges on access.
  def privilege
    super || self.privilege = Privilege.new
  end

  # Check the old password before saving the record.
  def check_old_password_before_save
    @check_old_password_before_save = true
  end

  # Ist it necessary to check the old password before saving thwe record?
  def check_old_password_before_save?
    !! @check_old_password_before_save
  end

  # Sets a fresh login hash and returns it.
  def refresh_login_hash
    self.login_hash = unique_hash
  end

  # Sets a fresh login hash and saves it in the database.
  #
  #   if user.refresh_login_hash!
  #     session[:login_hash] = user.login_hash
  #   end
  #
  # Returns true on success, else false.
  def refresh_login_hash!
    refresh_login_hash
    save
  end

  # Returns a ActiveRecord::Relation with lists accessible for the user.
  def accessible_lists
    List.accessible_for(self)
  end

  # Returns a string containing prename and name of the user.
  #
  #   user.full_name
  #   #=> "Bill Murray"
  def full_name
    "#{prename} #{name}"
  end

  alias :to_s :full_name

  # Sets the fields for the JSON representation of the user.
  def as_json(options = {})
    super(options.merge(only: [:id, :name, :prename]))
  end

  private

  # Returns a unique hash.
  def unique_hash
    Digest::SHA1.hexdigest(SecureRandom::uuid)
  end
end
