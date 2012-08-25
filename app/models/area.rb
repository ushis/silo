class Area < ActiveRecord::Base
  require_dependency 'country'

  attr_accessible :area

  validates :area, presence: true, uniqueness: true

  has_many :countries

  default_scope order(:area).includes(:countries)

  def ordered_countries
    Rails.cache.fetch("countries_#{area}_#{I18n.locale}") do
      countries.sort { |x, y| x.human <=> y.human }
    end
  end

  def human
    I18n.t(area, scope: :areas)
  end
end
