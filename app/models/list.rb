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
# A title must be present.
class List < ActiveRecord::Base
  attr_accessible :title

  validates :title, presence: true

  has_and_belongs_to_many :experts,  uniq: true, include: :country
  has_and_belongs_to_many :partners, uniq: true, include: :country

  has_many :current_users, class_name: :User, foreign_key: :current_list_id

  belongs_to :user

  # Hash of all possible list item types.
  ITEM_TYPES = Hash[
    reflect_on_all_associations(:has_and_belongs_to_many).map { |r| [r.name, r] }
  ]

  scope :with_items, includes(ITEM_TYPES.keys)

  default_scope order('lists.private DESC, lists.title ASC')

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
  # - *:title*    A (partial) title
  # - *:private*  Wether the list should be private or not.
  #
  # Returns a ActiveRecord::Relation.
  def self.search(params)
    rel = self

    unless params[:title].blank?
      rel = rel.where('title LIKE ?', "%#{params[:title]}%")
    end

    unless params[:private].blank?
      rel = rel.where(private: params[:private])
    end

    rel
  end

  # Checks if a list is accessible for a user. Returns true if the user
  # has access to the list else false.
  def accessible_for?(user)
    ! private? || user_id == user.try(:id)
  end

  # Returns a copy of the list with all its list items.
  def copy
    copy = dup

    ITEM_TYPES.keys.each do |assoc|
      copy.association(assoc).ids_writer(association(assoc).ids_reader)
    end

    copy
  end

  # Adds one or more items to the list.
  #
  #   list.add(:experts, 12)
  #   #=> [#<Expert id: 12>]
  #
  #   list.add(:experts, [13, 44])
  #   #=> [#<Expert id: 13>, #<Expert id: 44>]
  #
  #   list.experts
  #   #=> [#<Expert id: 12>, #<Expert id: 13>, #<Expert id: 44>]
  #
  # Returns a collection of the added items.
  def add(item_type, item_ids)
    association, item_class = item_info(item_type)

    connection.transaction do
      item_class.where(id: item_ids).each do |item|
        begin
          association << item
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end
  end

  # Removes one or more items from the list.
  #
  #   list.partners
  #   #=> [#<Partner id: 42>, #<Partner id: 11>, #<Partner id: 43>]
  #
  #   list.remove(:partners, 42)
  #   #=> [#<Partner id: 42>]
  #
  #   list.remove(:partners, [11, 43])
  #   #=> [#<Partner id: 11>, #<Partner id: 43>]
  #
  #   list.partners
  #   #=> []
  #
  # Returns a collection of the removed items.
  def remove(item_type, item_ids)
    association, item_class = item_info(item_type)
    association.delete(item_class.where(id: item_ids))
  end

  # Adds the list items to the JSON reprensentation.
  def as_json(options = {})
    super(options.merge(include: ITEM_TYPES.keys))
  end

  private

  # Returns the association and the model class for the specified item type.
  def item_info(item_type)
    type = ITEM_TYPES.fetch(item_type)
    [send(type.name), type.class_name.constantize]
  rescue KeyError
    raise ArgumentError, "Ivalid item type: #{item_type}"
  end
end
