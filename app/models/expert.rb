#
#
class Expert < ActiveRecord::Base
  attr_accessible(:name, :prename, :gender, :birthname, :birthday,
                  :birthplace, :citizenship, :degree, :marital_status)

  after_initialize :init_contact

  has_one    :contact,   as: :contactable, autosave: true, dependent: :destroy
  has_many   :addresses, as: :addressable, autosave: true, dependent: :destroy
  belongs_to :user

  default_scope includes(:contact)

  #
  CONST_VALUES = {
    gender:         { female: 'f',  male: 'm' },
    marital_status: { married: 'm', single: 's' }
  }

  #
  CONST_VALUES.each do |method, values|
    define_method(method) do
      values.find { |_, val| val == super() }.try(:[], 0)
    end

    define_method("#{method}=") { |sym| super(values[sym]) }
  end

  #
  def self.gender
    CONST_VALUES[:gender]
  end

  #
  def self.marital_status
    CONST_VALUES[:marital_status]
  end

  #
  def init_contact
    self.contact ||= Contact.new
  end
end
