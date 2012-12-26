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
    klass = List.reflect_on_association(@item_type).klass
    cols = klass.exposable_attributes(@options.merge(human: true))
    items = @record.send(@item_type)

    h2 @item_type

    if cols.empty? || items.empty?
      p '-'
    else
      items_table(klass, cols, items)
    end
  end

  # Renders the items table.
  def items_table(klass, cols, items)
    data = []

    data << cols.map do |col|
      klass.human_attribute_name(col[0])
    end

    data += items.map do |item|
      cols.map { |col| item.send(col[1]).to_s }
    end

    table data
  end
end
