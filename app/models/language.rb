# The Language model provides access to a bunge of language codes.
#
# Database scheme:
#
# - *id* integer
# - *language* string
#
# Alone it is quite useless, but in combination with the polymorphic Lang
# model it provides the possibility to associate an arbitrary model with one
# or more languages.
#
#   class Something < ActiveRecord::Base
#     has_many :lang
#     has_and_belongs_to_many :languages, through: :lang
#   end
#
# The Language#human method provides access to localized language names.
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

  # Return the localized language.
  def to_s
    human
  end
end
