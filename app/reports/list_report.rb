# The ListReport renders a list in PDF.
class ListReport < ApplicationReport

  # Builds a list report.
  def initialize(list, item_type, user, options = {})
    super(list, user, layout: :landscape)
    @item_type = item_type
    @options = options
    text list.comment.to_s
    gap
    items
  end

  private

  # Adds the list items.
  def items
    klass = ListItem.class_for_item_type(@item_type)
    cols = klass.exposable_attributes(:pdf, only: @options[:attributes], human: true)
    incl = klass.filter_associations(cols.map(&:first))
    items = @record.list_items.includes(item: incl).by_type(@item_type, order: true)

    h2 @item_type

    if cols.empty? || items.empty?
      p '-'
    else
      items_table(items, cols, klass)
    end
  end

  # Renders the items table.
  def items_table(list_items, cols, klass)
    note = !! @options[:note]
    head = cols.map { |attr, _| klass.human_attribute_name(attr) }
    head << ListItem.human_attribute_name(:note) if note

    data = [head]

    data += list_items.map do |list_item|
      row = cols.map { |_, method| list_item.item.send(method).to_s }
      row << list_item.note if note
      row
    end

    table data
  end
end
