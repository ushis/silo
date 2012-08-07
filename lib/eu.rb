# Checks if a country code references an EU country.
module Eu

  # A list of all countries of the EU.
  EU_COUNTRIES = [:BE, :BG, :DK, :DE, :EE, :FI, :FR, :GR, :IE,
                  :IT, :LV, :LT, :LU, :MT, :NL, :AT, :PL, :PT,
                  :RO, :SE, :SK, :SI, :ES, :CZ, :HU, :GB, :CY]

  # Checks if a country code references an EU country.
  def self.eu?(c)
    (c.is_a?(String) || c.is_a?(Symbol)) && EU_COUNTRIES.include?(c.to_sym)
  end
end
