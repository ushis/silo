# The List model provides the ability to group other models in lists.
#
# Database schema:
#
# - *id:*         integer
# - *user_id*     integer
# - *title*       string
# - *private*     boolean
# - *created_at*  datetime
# - *updated_at*  datetime
#
# A title must be present and unique.
class List < ActiveRecord::Base
  attr_accessible :title

  validates :title, presence: true, uniqueness: true

  has_and_belongs_to_many :experts, uniq: true
  has_and_belongs_to_many :partners, uniq: true

  has_many :current_users, class_name: :User, foreign_key: :current_list_id

  belongs_to :user

  # Hash of all possible list item types.
  ITEM_TYPES = Hash[
    reflect_on_all_associations(:has_and_belongs_to_many).map { |r| [r.name, r] }
  ]

  scope :with_items, includes(ITEM_TYPES.keys)

  # Selects lists, that are accessible for a user, which means that they
  # are associated with the user or that they are not private.
  #
  #   current_user.id  #=> 2
  #
  #   List.accessible_fur(current_user)
  #   #=> [
  #   #     #<List id: 21, user_id: 2, private: true>,
  #   #     #<List id: 33, user_id: 2, private: false>,
  #   #     #<List id: 11, user_id: 7, private: false>
  #   #   ]
  #
  # Returns a ActiveRecord::Relation.
  def self.accessible_for(user)
    where('lists.user_id = ? OR lists.private = 0', user)
  end

  # Searches for lists. Taks a hash of conditions:
  #
  # - *:title*  A (partial) title
  # - *:user*   A user or a user id.
  #
  # Returns a ActiveRecord::Relation.
  def self.search(params)
    rel = self

    unless params[:title].blank?
      rel = rel.where('title LIKE ?', "%#{params[:title]}%")
    end

    unless params[:user].blank?
      rel = rel.where(user_id: params[:user])
    end

    rel.order(:title)
  end

  # Adds an item to the list.
  #
  #   list.add(:experts, 12)
  #   #=> [#<Expert id: 3>, #<Expert id: 12>]
  #
  # Returns the list containing the items of the specified type or
  # false on error.
  def add(item_type, item_id)
    process_item(:<<, item_type, item_id)
  end

  # Removes an item from the list.
  #
  #   list.remove(:partners, 42)
  #   #=> #<Partner id: 42>
  #
  # Returns the removed item or false on error.
  def remove(item_type, item_id)
    process_item(:delete, item_type, item_id)
  end

  # Adds the list items to the JSON reprensentation.
  def as_json(options = {})
    super(options.merge(include: ITEM_TYPES.keys))
  end

  private

  # Removes or adds an item from/to the list.
  #
  #   list.process_item(:<<, :experts, 12)
  #   #=> [#<Expert id: 3>, #<Expert id: 12>]
  #
  # The return value depends on the specified operation. On error,
  # false is returned.
  def process_item(op, item_type, item_id)
    if (type = ITEM_TYPES[item_type.to_s.to_sym])
      send(type.name).send(op, type.class_name.constantize.find(item_id))
    end
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    false
  end
end
