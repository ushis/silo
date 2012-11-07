# Defines several list related helpers.
module ListHelper

  # Renders a "Remove item from this list" link.
  def remove_from_list_tag(list, record, options = {})
    options = {
      method: :delete,
      class: 'icon-removefromlist'
    }.merge(options)

    link_to(t('actions.remove'), [list, record], options)
  end

  # Creates an "open this list" link.
  def open_list_tag(list)
    options = {
      remote: true,
      method: :put,
      'data-id' => list.id,
      'data-type' => :json,
      class: 'icon-folder-open open-list'
    }

    link_to(t('actions.open'), open_ajax_list_path(list), options)
  end

  # Generic helper to create "listable" tags. You should not use this
  # directly. There are higher level methods for each listable resource.
  #
  #  # Create a "listable" tag for an expert.
  #  listable_expert_tag(expert)
  #
  #  # Create a "listable" tag for a partner with his name inside.
  #  <%= listable_partner_tag(partner) do %>
  #     <span><%= partner.name %></span>
  #  <% end %>
  #
  # Returns a string.
  def listable_tag(record, item_type, url_method_name, &block)
    options = {
      remote: true,
      'data-id' => record.id,
      'data-type' => :json,
      'data-item-type' => item_type,
      class: 'listable'
    }

    txt = block.nil? ? '' : capture(&block)
    link_to(txt, send(url_method_name, list_id: :current), options)
  end

  # Defines the listable_{resource}_tag for all listable resources. See
  # ListHelper#listable_tag for mroe info.
  List::ITEM_TYPES.keys.each do |type|
    resource = type.to_s.singularize

    define_method(:"listable_#{resource}_tag") do |record, &block|
      listable_tag(record, type, :"ajax_list_#{type}_path", &block)
    end
  end
end
