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

  # Adds a where condition with a proper item type to the relation.
  #
  # Raises ArgumentError for invalid item types.
  def self.by_type(item_type)
    where(item_type: class_for_item_type(item_type).to_s)
  end

  # Returns a collection of fresh ListItem objects, generated from an item
  # type and a set of ids.
  #
  #   ListItem.collection(:experts, [1, 2, 3])
  #   #=> [
  #         #<ListItem id: nil, item_id: 1, item_type: "Expert">,
  #         #<ListItem id: nil, item_id: 2, item_type: "Expert">,
  #         #<ListItem id: nil, item_id: 3, item_type: "Expert">
  #       ]
  #
  # Raises ArgumentError for invalid item types.
  def self.collection(item_type, item_ids)
    class_for_item_type(item_type).where(id: item_ids).map do |item|
      new.tap { |list_item| list_item.item = item }
    end
  end

  # Returns a copy of the list item. By default the note of the copy is
  # erased. Pass _false_ to prevent this behavior.
  def copy(unset_note = true)
    dup.tap { |copy| copy.note = nil if unset_note }
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
