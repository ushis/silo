# The ListReport renders a list in PDF.
class ListReport < ApplicationReport

  # Builds a list report.
  def initialize(list, item_type, user, options = {})
    super(list, user, list.title, layout: :landscape)
    @item_type = item_type
    @options = options

    text list.comment.to_s
    gap
    items
  end

  private

  # Adds the list items.
  def items
    h2 @item_type

    model = List.reflections.fetch(@item_type).options[:source_type].constantize
    cols = model.exposable_attributes(@options.merge(human: true))
    items = @record.send(@item_type)

    if cols.empty? || items.empty?
      p '-'
      return
    end

    data = []

    data << cols.map do |col|
      model.human_attribute_name(col[0])
    end

    data += items.map do |item|
      cols.map { |col| item.send(col[1]).to_s }
    end

    table data
  end
end
