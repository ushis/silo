# Defines several list related helpers.
module ListHelper

  # Renders a "Remove item from this list" link.
  def remove_from_list_button_for(list, record, options = {})
    options = {
      method: :delete,
      class: 'icon-removefromlist'
    }.merge(options)

    link_to(t('actions.remove'), [list, record], options)
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

  # Returns the lilstable url for the specified item type.
  def listable_url(item_type)
    send(:"ajax_list_#{item_type}_path", list_id: :current)
  end

  # Returns the item type for the specified record.
  def listable_type_for(record)
    record.class.name.downcase.pluralize
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
    options = { remote: true, 'data-type' => :json, class: 'listable' }

    case record_or_collection
    when Array, ActiveRecord::Relation
      return nil if record_or_collection.empty?
      options['data-ids'] = record_or_collection.map(&:id).join(' ')
      options['data-item-type'] = listable_type_for(record_or_collection.first)
    when ActiveRecord::Base
      options['data-ids'] = record_or_collection.id
      options['data-item-type'] = listable_type_for(record_or_collection)
    else
      raise TypeError, "First argument is wether a record nor a collection."
    end

    txt = block.nil? ? '' : capture(&block)
    link_to(txt, listable_url(options['data-item-type']), options)
  end
end
