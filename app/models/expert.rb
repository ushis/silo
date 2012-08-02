#
#
class Expert < ActiveRecord::Base
  attr_accessible(:name, :prename, :gender, :birthname, :birthday,
                  :birthplace, :citizenship, :degree, :marital_status)

  has_one    :contact,   as: :contactable, autosave: true, dependent: :destroy
  has_many   :addresses, as: :addressable, autosave: true, dependent: :destroy
  belongs_to :user

  #
  GENDERS = { male: 'male', female: 'female' }

  #
  MARITAL_STATUS = { single: 'single', married: 'married' }

  #
  def self.genders
    GENDERS
  end

  #
  def self.marital_status
    MARITAL_STATUS
  end
end
