# The Expert model.
class Expert < ActiveRecord::Base
  attr_accessible(:name, :prename, :gender, :birthname, :birthday,
                  :birthplace, :citizenship, :degree, :marital_status)

  after_initialize :init_contact

  has_one    :contact,   as: :contactable, autosave: true, dependent: :destroy
  has_many   :addresses, as: :addressable, autosave: true, dependent: :destroy
  belongs_to :user

  default_scope includes(:contact)

  # Lookup for database <-> application translations. Defines database values
  # for _gender_ and _marital_status_.
  TRANSLATIONS = {
    gender:         { female: 'f',  male: 'm' },
    marital_status: { married: 'm', single: 's' }
  }

  # Defines class methods returning translation hashes.
  #
  #   Expert.gender
  #   #=> { female: 'f', male: 'm' }
  #
  # Defines the methods _Expert.gender_ and _Expert.marital_status_.
  class << self
    TRANSLATIONS.each do |method, values|
      define_method(method) { values }
    end
  end

  # Defines instance methods to access the TRANSLATIONS hash. For each
  # translation hash a getter method, translating the database value to
  # a symbol, and a setter method, translating a symbol to the corresponding
  # database value, is defined.
  #
  #   # Get the symbol for db value 'f'
  #   expert.gender
  #   #=> :female
  #
  #   # Sets db value to 'm'
  #   expert.gender = :male
  #   #=> :male
  #
  # If the setter method gets a non-symbol argument, the value is assigned
  # without translation.
  TRANSLATIONS.each do |method, values|
    define_method(method) do
      values.find { |_, val| val == super() }.try(:[], 0)
    end

    define_method("#{method}=") do |val|
      if val.is_a? Symbol
        super(values[val])
      else
        super(val)
      end
    end
  end

  # Initializes the contact.
  def init_contact
    self.contact ||= Contact.new
  end
end
