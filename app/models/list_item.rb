# The ListItem model provides the ability to connect arbitrary models with
# the List model and add some notes to them.
#
# Database schema:
#
# - *id:*          integer
# - *list_id:*     integer
# - *item_id:*     integer
# - *item_type:*   string
# - *note:*        string
# - *created_at:*  datetime
# - *updated_at:*  datetime
#
# There is a unique index over list_id, item_id and item_type.
class ListItem < ActiveRecord::Base
  attr_accessible :note

  belongs_to :list
  belongs_to :item, polymorphic: true

  # Hash containing possible item types.
  TYPES = { experts: Expert, partners: Partner }

  # Setup a belongs to association for each item type.
  TYPES.each_value do |klass|
    belongs_to klass.to_s.downcase.to_sym,
               foreign_key: :item_id,
               conditions: "list_items.item_type = '#{klass}'"
  end

  # Returns the model class for an item type.
  #
  #   ListItem.class_for_item_type(:experts)
  #   #=> Expert(id: integer, ...)
  #
  # Raises ArgumentError for invalid item types.
  def self.class_for_item_type(item_type)
    TYPES.fetch(item_type)
  rescue KeyError
    raise ArgumentError, "Invalid item type: #{item_type}"
  end

  # Adds a proper condition to the scope, to filter list items with a the
  # specified item type. Set the order option, to get the list items ordered
  # by their actual items default value.
  #
  #   List.list_items.by_type(:experts, order: true)
  #   #=> [
  #   #     #<ListItem id: 35, item_id: 13, item_type: "Expert">,
  #   #     #<ListItem id: 14, item_id: 37, item_type: "Expert">
  #   #   ]
  #
  # Raises ArgumentError for invalid item types.
  def self.by_type(item_type, options = {})
    klass = class_for_item_type(item_type)
    scope = joins(klass.to_s.downcase.to_sym)
    options[:order] ? scope.order(klass::DEFAULT_ORDER) : scope
  end

  # Returns a collection of fresh ListItem objects, generated from an item
  # type and a set of ids.
  #
  #   ListItem.collection(:experts, [1, 2, 3])
  #   #=> [
  #   #     #<ListItem id: nil, item_id: 1, item_type: "Expert">,
  #   #     #<ListItem id: nil, item_id: 2, item_type: "Expert">,
  #   #     #<ListItem id: nil, item_id: 3, item_type: "Expert">
  #   #   ]
  #
  # Raises ArgumentError for invalid item types.
  def self.collection(item_type, item_ids)
    class_for_item_type(item_type).where(id: item_ids).map do |item|
      new.tap { |list_item| list_item.item = item }
    end
  end

  # Returns a copy of the list item after merging the optional attributes.
  def copy(attributes = {})
    dup.tap { |copy| copy.attributes = attributes }
  end

  # Returns the name of the list item.
  def name
    item.to_s
  end

  alias :to_s :name

  # Adds the name to the JSON representation of the list item.
  def as_json(options = {})
    super(options.merge(methods: [:name]))
  end
end
