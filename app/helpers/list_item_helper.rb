module ListItemHelper

  # Renders a print list dialog for a given item type. It yields the print
  # options in a nested array. Use it this way:
  #
  #   <%= print_list_dialog_for(:experts, @list_id) do |options| %>
  #     <% options.each do |name, attr, human| %>
  #       <label>
  #         <%= check_box_tag(name, attr, true) %> <%= human %>
  #       </label>
  #     <% end %>
  #   <% end %>
  #
  # Raises an ArgumentError for invalid item types.
  def print_list_dialog_for(item_type, list_id)
    klass = ListItem.class_for_item_type(item_type)

    url = url_for({
      controller: '/list_items',
      action: item_type,
      list_id: list_id,
      format: :pdf
    })

    form_tag(url, method: :get) do
      yield(options_for_print_list_dialog(klass))
    end
  end

  private

  # Returns a nested array of options used by the print dialog
  # in the list view.
  def options_for_print_list_dialog(klass)
    klass.exposable_attributes(:pdf).map do |attr|
      ['attributes[]', attr, klass.human_attribute_name(attr)]
    end << [:note, :note, ListItem.human_attribute_name(:note)]
  end
end
