require 'set'
require 'digest/sha1'
require 'securerandom'

# The User model provides access to the users data and several methods for
# manipulation.
#
# Database scheme:
#
# - *id* integer
# - *username* string
# - *email* string
# - *password_digest* string
# - *login_hash* string
# - *name* string
# - *prename* string
# - *locale* string
# - *created_at* datetime
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
  attr_accessible(:email, :password, :password_confirmation, :name, :prename,
                  :locale)

  has_secure_password

  validates :password,   presence: true,  on: :create
  validates :username,   presence: true,  uniqueness: true, format: /\A[a-z0-9]+\z/
  validates :email,      presence: true,  uniqueness: true
  validates :login_hash, allow_nil: true, uniqueness: true
  validates :name,       presence: true
  validates :prename,    presence: true

  has_many :experts
  has_one  :privilege, autosave: true, dependent: :destroy

  default_scope includes(:privilege)

  # Available localizations
  LOCALES = I18n.available_locales.to_set

  # Returns a valid locale symbol for a value using the LOCALES constant.
  #
  #   User.locale('en')
  #   #=> :en
  #
  # If no valid symbol is found, the first symbol of LOCALES is returned.
  def self.locale(locale)
    l = locale.try(:to_sym)
    LOCALES.include?(l) ? l : LOCALES.first
  end

  # Auto initializes the users privileges on access.
  def privilege
    super || self.privilege = Privilege.new
  end

  # Returns the users preferred locale.
  def locale
    User.locale(super)
  end

  # Sets the users preferred locale. If the given locale value is not found
  # in the LOCALES list, a default locale is assigned.
  def locale=(locale)
    super(User.locale(locale).to_s)
  end

  # Checks for admin privileges.
  #
  #   if user.admin?
  #     secure_operation(sensitive_data)
  #   end
  #
  # Returns true if user has admin privileges, else false.
  def admin?
    privilege.admin
  end

  # Checks for access privileges for a specified section.
  #
  #   if user.access?(:experts)
  #     write_some_experts_data(data)
  #   end
  #
  # Returns true if access is granted, else false.
  def access?(section)
    admin? || privilege.send(section)
  end

  # Alias for Privilege#privileges.
  #
  #   user.privileges
  #   #=> { experts: true, partners: false, references: true }
  #
  # If the user is admin, the hash contains the single key _admin_ with
  # the value _true_.
  def privileges
    privilege.privileges
  end

  # Sets the users privileges. It takes a hash of sections and their
  # corresponding access values.
  #
  #   user.privileges = { experts: true, references: false }
  #   user.privileges
  #   #=> { experts: true, partners: false, references: false }
  #
  # If the _admin_ is set to true, all sections will be set to true.
  def privileges=(privileges)
    self.privilege.admin = privileges[:admin]

    Privilege::SECTIONS.each do |section|
      self.privilege.send("#{section}=", admin? || privileges[section])
    end
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

  # Returns a string containing prename and name of the user.
  #
  #   user.full_name
  #   #=> "Bill Murray"
  def full_name
    "#{prename} #{name}"
  end

  private

  # Returns a unique hash.
  def unique_hash
    Digest::SHA1.hexdigest(SecureRandom::uuid)
  end
end
