require 'set'

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

  # A set of prioritized language codes.
  PRIORITIES = [:de, :en, :es, :fr].to_set

  # Polymorphic language finder. Can handle Language, Fixnum, Symbol and
  # String arguments. Raises an ArgumentError in case of invalid input.
  #
  #   Language.find_language(1)
  #   #=> #<Language id: 1, language: "af">
  #
  #   Language.find_language(:en)
  #   #=> #<Language id: 12, language: "en">
  #
  #   Language.find_language("de")
  #   #=> #<Language id: 10, language: "de">
  #
  #   Language.find_language("43")
  #   #=> #<Language id: 43, language: "mt">
  #
  # Returns nil, if no language could be found.
  def self.find_language(language)
    case language
    when Language
      language
    when Fixnum
      find_by_id(language)
    when Symbol
      find_by_language(language)
    when String
      (id = language.to_i) > 0 ? find_by_id(id) : find_by_language(language)
    else
      raise ArgumentError, 'Argument is nor Language, Fixnum, Symbol or String'
    end
  end

  # Returns a collection of all languages ordered by priority and localized
  # lagnuage name.
  def self.priority_ordered
    @priority_ordered ||= Rails.cache.fetch("languages_#{I18n.locale}") do
      all.sort do |x, y|
        if x.prioritized? == y.prioritized?
          x.human <=> y.human
        else
          x.prioritized? ? -1 : 1
        end
      end
    end
  end

  # Returns an array of all priority ordered ordered languages in a select
  # box friendly format:
  #
  #   Language.select_box_friendly
  #   #=> [['English', 12], ['German', 6], ['Arabic', 78], ...]
  def self.select_box_friendly
    priority_ordered.collect { |lang| [lang.human, lang.id] }
  end

  # Returns true if the language has priority, else false. The PRIORITIES
  # constant is used to determine the value.
  def prioritized?
    @prioritized ||= PRIORITIES.include?(language.to_sym)
  end

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
