#
class Language < ActiveRecord::Base
  attr_accessible :language

  validates :language, presence: true, uniqueness: true

  has_one  :cv
  has_many :langs,   dependent: :destroy
  has_many :experts, through:   :langs

  # Returns the localized language.
  #
  #   cv.language.human
  #   #=> 'English'
  def human
    I18n.t(language, scope: :language)
  end
end
