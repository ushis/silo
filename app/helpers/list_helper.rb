# Defines several list related helpers.
module ListHelper

  # Renders a link to the current list.
  def link_to_current_list
    if current_list
      link_to current_list.try(:title), list_experts_path(list_id: current_list)
    else
      link_to nil, lists_path
    end
  end

  # Renders a "print this list" button.
  def print_list_button_for(list, item_type)
    options = {
      url: send("print_ajax_list_#{item_type}_path", list),
      class: 'icon-print hidden-form'
    }

    link_to(t('actions.print'), options.delete(:url), options)
  end

  # Renders a "Remove item from this list" link.
  def remove_from_list_button_for(list, list_item, options = {})
    options = {
      method: :delete,
      class: 'icon-removefromlist'
    }.merge(options)

    link_to(t('actions.remove'), [list, list_item], options)
  end

  # Renders a "share this list" button.
  def share_list_button_for(list)
    options = {
      method: :put,
      data: { '[list][private]' => 0 },
      class: 'icon-globe'
    }

    options[:class] << ' disabled' unless list.private?
    link_to(t('actions.share'), list_path(list, options.delete(:data)), options)
  end

  # Creates an "open this list" link.
  def open_list_button_for(list)
    options = {
      remote: true,
      method: :put,
      'data-id' => list.id,
      'data-type' => :json,
      class: 'icon-folder-open open-list'
    }

    link_to(t('actions.open'), open_ajax_list_path(list), options)
  end

  # Creates a "import this list into that list" button.
  def import_list_button_for(list, other)
    options = {
      method: :put,
      'data-other' => other.id,
      class: 'icon-addtolist'
    }

    link_to(t('actions.import'), concat_list_path(list), options)
  end

  # Returns the lilstable url for the specified item type.
  def listable_url(item_type)
    send(:"ajax_list_#{item_type}_path", list_id: :current)
  end

  # Renders a listable button for a single record or a collection of records.
  #
  #   listable_button_for(expert)
  #   #=> '<a href="/ajax/lists/current/experts" data-ids="432" ...></a>'
  #
  #   listable_button_for(partners)
  #   #=> '<a href="/ajax/lists/current/partners" data-ids="12 54 7" ...></a>'
  #
  # If a block is given, it is captured and used as the buttons content.
  def listable_button_for(record_or_collection, &block)
    collection = Array.wrap(record_or_collection)

    return nil if collection.empty?

    options = {
      remote: true,
      'data-type' => :json,
      'data-ids' => collection.map(&:id).join(' '),
      'data-item-type' => ListItem::TYPES.key(collection.first.class),
      class: 'listable'
    }

    options['data-params'] = "ids=#{options['data-ids']}"
    url = listable_url(options['data-item-type'])

    if block_given?
      link_to(url, options, &block)
    else
      link_to(content_tag(:div, nil, class: 'marker'), url, options)
    end
  end
end
