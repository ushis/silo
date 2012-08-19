require 'set'

# The Country model provides the ability to associate arbitrary models with
# one or more countries.
class Country < ActiveRecord::Base
  attr_accessible :country, :continent

  validates :country, uniqueness: true

  # Polymorphic method to find a country.
  #
  #   Country.find_country("GB")
  #   #=> #<Country id: 77, country: "GB", continent: "EU">
  #
  # Returns nil, if no country is found.
  def self.find_country(country)
    case country
    when Country
      country
    when Fixnum, Array
      find_by_id(country)
    when Symbol
      find_by_country(country)
    when String
      (id = country.to_i) > 0 ? find_by_id(id) : find_by_country(country)
    else
      nil
    end
  end

  # Returns a collection of all countries ordered by localized country name-
  def self.ordered
    Rails.cache.fetch("countries_#{I18n.locale}") do
      all.sort { |x, y| x.human <=> y.human }
    end
  end

  # Returns a list of tuples containing the continent name and a list of
  # country tuples ordered by localized country name.
  #
  #   Country.ordered_by_continent
  #   #=> [
  #   #     ["Afrika", [["Algeria", 62], ["Angole", 8], ...]],
  #   #     ["Europe", [["Austria", 12], ...]],
  #   #     ...
  #   #   ]
  def self.grouped_by_continent
    Rails.cache.fetch("countries_by_continent_#{I18n.locale}") do
      map = ActiveSupport::OrderedHash.new

      order(:continent).all.each do |country|
        map[country.human_continent] ||= SortedSet.new
        map[country.human_continent] << [country.human, country.id]
      end

      map.to_a
    end
  end

  # Returns the localized country name.
  def human
    I18n.t(country, scope: :countries)
  end

  # Returns the localized continent name.
  def human_continent
    I18n.t(continent, scope: :continents)
  end
end
