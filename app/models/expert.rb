# The Expert model provides access to the experts data and several methods
# for manipulation.
#
# Database scheme:
#
# - *id* integer
# - *user_id* integer
# - *name* string
# - *prename* string
# - *gender* string
# - *birthname* string
# - *birthday* string
# - *birthplace* string
# - *citizenship* string
# - *degree* string
# - *marital_status* string
# - *former_collaboration* boolean
# - *fee* string
# - *created_at* datetime
# - *updated_at* datetime
#
# Several attributes have a constant list of possible values, defined in
# CONSTANTS, such as _gender_ and _marital_status_. The getter methods of
# these attributes return symbols. The setter methods try to convert the
# assigned value into a symbol, found in CONSTANTS. If no symbol is found
# a default value is assigned.
#
#   # Make expert female
#   expert.gender = 'female'
#   expert.gender
#   #=> :female
#
#   # Assign an invalid value
#   expert.gender = 'tiger'
#   expert.gender
#   #=> :male
class Expert < ActiveRecord::Base
  attr_accessible(:name, :prename, :gender, :birthname, :birthday,
                  :birthplace, :citizenship, :degree, :marital_status,
                  :former_collaboration, :fee)

  has_one    :contact,   autosave: true, dependent: :destroy, as: :contactable
  has_one    :comment,   autosave: true, dependent: :destroy, as: :commentable
  has_many   :addresses, autosave: true, dependent: :destroy, as: :addressable
  has_many   :cvs,       autosave: true, dependent: :destroy
  belongs_to :user

  default_scope includes(:contact)

  # Defines constant values for specific attributes, such as gender and
  # marital_status. For each attribute listed in this hash, a getter and
  # a setter method is defined, ensuring that the values are valid.
  CONSTANTS = {
    gender: [:female, :male],
    marital_status: [:married, :single]
  }

  # Defines class methods returning a constant from CONSTANTS for a given
  # value. If not correspong constant is found, the last one is returned.
  #
  #   Expert.gender('female')
  #   #=> :female
  #
  # Defines the methods _Expert.gender_ and _Expert.marital_status_.
  class << self
    CONSTANTS.each do |method, values|
      define_method(method) do |lookup|
        values.find { |val| val == lookup.try(:to_sym) } || values.last
      end
    end
  end

  # Defines instance methods to access the CONSTANTS hash. For each
  # key a getter method, translating the database value to a symbol,
  # and a setter method, translating a symbol to the corresponding
  # database value, is defined.
  #
  #   expert.gender
  #   #=> :female
  #
  #   expert.gender = :male
  #   #=> :male
  #
  # If the assigned/saved value is not in the CONSTANTS hash, a default
  # value is assigned/returned.
  CONSTANTS.each do |method, values|

    # Define getter methods
    define_method(method) do
      Expert.send(method, super())
    end

    # Define setter methods
    define_method("#{method}=") do |val|
      super(Expert.send(method, val).to_s)
    end
  end

  # Initializes the contact on access, if not already initalized.
  def contact
    super || self.contact = Contact.new
  end

  # Initializes the comment on access, if not already initialized.
  def comment
    super || self.comment = Comment.new
  end

  # Returns a string containing name and prename.
  def full_name
    "#{name}, #{prename}"
  end

  # Returns the experts age or nil if the birthday is unknown.
  #
  #   expert.age
  #   #=> 43
  def age
    return nil unless birthday

    now = Time.now.utc.to_date
    age = now.year - birthday.year

    if now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)
      age - 1
    else
      age
    end
  end
end
