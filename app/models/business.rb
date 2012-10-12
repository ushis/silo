require 'set'

# The Business model provides the possibility to add several industry sectors
# to the partner companies. It is like tagging the partners. Use it this way:
#
#   partner.businesses = Business.from_s('Biodiversity, Banana Cultivation')
#   #=> [
#   #     #<Business id: 12, business: 'Biodiversity'>,
#   #     #<Business id: nil, business: 'Banana Cultivation'>
#   #   ]
#
# Database schema:
#
# - *id*        integer
# - *business*  string
#
# The business attribute is unique.
class Business < ActiveRecord::Base
  attr_accessible :business

  validates :business, presence: true, uniqueness: true

  has_and_belongs_to_many :partners, uniq: true

  # Extracts businesses from a string using a specified delimiter and returns
  # an Array of existing or new initialized Business objects. The default
  # delimiter is a comma.
  #
  #   Business.from_s('Biodiversity, Banana Cultivation')
  #   #=> [
  #   #     #<Business id: 12, business: 'Biodiversity'>,
  #   #     #<Business id: nil, business: 'Banana Cultivation'>
  #   #   ]
  #
  # The extracted strings were stripped and duplicates were removed.
  def self.from_s(s, delimiter = /\s*,\s*/)
    results = s.split(delimiter).inject(Set.new) do |set, business|
      business.blank? ? set : set << business.strip
    end

    results.empty? ? [] : multi_find_or_initialize_by_business(results.to_a)
  end

  # Finds multiple businesses and initializes the new ones.
  #
  #   Business.multi_find_or_initialize(['Biodiversity', 'Banana Cultivation'])
  #   #=> [
  #   #     #<Business id: 12, business: 'Biodiversity'>,
  #   #     #<Business id: nil, business: 'Banana Cultivation'>
  #   #   ]
  #
  # Returns an Array of Business objects.
  def self.multi_find_or_initialize_by_business(businesses)
    results = where(business: businesses).each do |business|
      businesses.delete(business.business)
    end

    results += businesses.collect { |b| Business.new(business: b) }
  end

  # Returns the business attribute.
  def to_s
    business
  end
end
