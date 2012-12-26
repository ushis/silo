# The ExpertsReport provides report rendering of the reports for an Expert.
class ExpertReport < ApplicationReport

  # Builds the report.
  def initialize(expert, user)
    super(expert, user)
    info_table
    languages
    contacts
    addresses
    comment
  end

  private

  # Builds the languages section.
  def languages
    h2 :languages
    p (langs = @record.languages).empty? ? '-' : langs.map(&:to_s).join(', ')
    gap
  end

  # Builds the contacts
  def contacts
    h2 :contacts
    contacts_table
  end


  # Builds the addresses table.
  def addresses
    h2 :addresses
    @record.addresses.empty? ? p('-') : addresses_table
    gap
  end

  # Renders the addresses table
  def addresses_table
    data = []

    @record.addresses.each_slice(4) do |slice|
      data << slice.map do |address|
        "#{address.address}\n\n#{address.country.try(:to_s)}"
      end
    end

    table data do |table|
      table.row_colors = ['ffffff']
      table.columns(0..3).width = table.width / data.first.length
      table.cells.padding_bottom = 30
    end
  end
end
