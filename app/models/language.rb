require 'set'

# The Language model provides access to a bunge of language codes.
#
# Database scheme:
#
# - *id* integer
# - *language* string
#
# The Language#human method provides access to localized language names.
class Language < ActiveRecord::Base
  attr_accessible :language

  validates :language, presence: true, uniqueness: true

  has_and_belongs_to_many :experts, uniq: true

  has_many :cvs

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
    language.is_a?(self) ? language : find_languages(language).first
  end

  # Does the same as Language.find_language, but raises
  # ActiveRecord::RecordNotFound when no language could be found.
  def self.find_language!(language)
    if (result = find_language(language))
      result
    else
      raise ActiveRecord::RecordNotFound, "Couldn't find Language #{language}"
    end
  end

  # Finds languages by id or language code. Strings are splitted to find
  # multiple languages.
  #
  #   Language.find_languages([10, '12']).all
  #   #=> [#<Language id: 2, language: 'de'>, #<Language id: 4, language: 'en'>]
  #
  #   Language.find_languages('de en').all
  #   #=> [#<Language id: 2, language: 'de'>, #<Language id: 4, language: 'en'>]
  #
  # Returns a ActiveRecord::Relation.
  def self.find_languages(query)
    query = query.split if query.is_a?(String)

    where('languages.id IN (:q) OR languages.language IN (:q)', q: query)
  end

  # Returns a collection of all languages ordered by localized name.
  def self.ordered
    all.sort { |x, y| x.human <=> y.human }
  end

  # Returns a collection of all languages ordered by priority and localized
  # language name.
  def self.priority_ordered
    all.sort do |x, y|
      if x.prioritized? == y.prioritized?
        x.human <=> y.human
      else
        x.prioritized? ? -1 : 1
      end
    end
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
    I18n.t(language, scope: :languages)
  end

  alias :to_s :human
end
