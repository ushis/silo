#
class Country < ActiveRecord::Base
  attr_accessible :country, :continent

  validates :country, uniqueness: true

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

  def self.ordered
    Rails.cache.fetch("countries_#{I18n.locale}") do
      all.sort { |x, y| x.human <=> y.human }
    end
  end

  def self.select_box_friendly
    ordered.collect { |country| [country.human, country.id] }
  end

  def human
    I18n.t(country, scope: :countries)
  end

  def human_continent
    I18n.t(continent, scope: :continent)
  end
end
