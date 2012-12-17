# The Area model provides access to the areas data. It is used to group the
# countries from the Country model.
#
# Database scheme:
#
# - *id* integer
# - *area* string
class Area < ActiveRecord::Base
  attr_accessible :area

  validates :area, presence: true, uniqueness: true

  has_many :countries

  default_scope order(:area).includes(:countries)

  # Returns all areas and their countries, ordered by their localized name.
  def self.with_ordered_countries
    all.each do |area|
      area.countries.sort! { |x, y| x.human <=> y.human }
    end
  end

  # Returns the localized name of the area.
  def human
    I18n.t(area, scope: :areas)
  end

  alias :to_s :human
end
