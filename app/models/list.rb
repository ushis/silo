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
  attr_accessible :title, :private

  self.per_page = 50

  is_commentable_with :comment, autosave: true, dependent: :destroy, as: :commentable

  validates :title, presence: true
  validate  :public_list_can_not_be_set_to_private, on: :update

  has_many :list_items, autosave: true, dependent: :destroy
  has_many :current_users, class_name: :User, foreign_key: :current_list_id

  has_many :experts,  through: :list_items, source: :item, source_type: :Expert,  include: :country
  has_many :partners, through: :list_items, source: :item, source_type: :Partner, include: :country

  belongs_to :user

  scope :with_items, includes(ListItem::TYPES.keys)

  default_scope order('lists.private DESC, lists.title ASC')

  # Inits a list for a user and sets it to the users current_list.
  #
  #   list = List.new_for_user(params[:list], current_user)
  #   #=> #<List id: nil, title: 'Example'>
  #
  #   list.save                          #=> true
  #   list.user == current_user          #=> true
  #   current_user.current_list == list  #=> true
  #
  # Returns the new list object.
  def self.new_for_user(params, user)
    new(params).tap do |list|
      list.user = user
      list.current_users << user
    end
  end

  # Finds a list and checks if it is accessible for the given user.
  #
  #   user.id
  #   #=> 45
  #
  #   List.find_for_user(12, user)
  #   #=> #<List id: 12, user_id: 45, private: true>
  #
  # Raises ActiveRecord::RecordNotFound and UnauthorizedError.
  def self.find_for_user(id, user)
    find(id).tap do |list|
      raise UnauthorizedError unless list.accessible_for?(user)
    end
  end

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
  # - *:title*    A (partial) title.
  # - *:private*  Wether the list should be private or not.
  # - *:exclude*  A list or a collection of lists to exclude.
  #
  # Returns a ActiveRecord::Relation.
  def self.search(params)
    ListSearcher.new(params.slice(:title, :private, :exclude)).search
  end

  # Validates the value of private. It is not allowed to set public lists
  # private. Use List#copy instead.
  def public_list_can_not_be_set_to_private
    if private? && ! private_was
      errors.add(:private, I18n.t('messages.list.errors.public_to_private'))
    end
  end

  # Checks if a list is accessible for a user. Returns true if the user
  # has access to the list else false.
  def accessible_for?(user)
    public? || user_id == user.try(:id)
  end

  # Returns a copy of the list with all its list items.
  def copy
    dup.tap do |copy|
      copy.list_items = list_items.map { |item| item.copy(false) }
    end
  end

  # Adds one or more items to the list.
  #
  #   list.add(:experts, 12)
  #   #=> [#<ListItem id: 44, item_id: 12, item_type: 'Expert'>]
  #
  #   list.add(:experts, [13, 44])
  #   #=> [
  #   #     #<ListItem id: 15, item_id: 12, item_type: 'Expert'>,
  #   #     #<ListItem id: 16, item_id: 44, item_type: 'Expert'>,
  #   #   ]
  #
  #   list.experts
  #   #=> [#<Expert id: 12>, #<Expert id: 13>, #<Expert id: 44>]
  #
  # Returns a collection of the added items.
  def add(item_type, item_ids)
    add_collection(ListItem.collection(item_type, item_ids))
  end

  # Removes one or more items from the list.
  #
  #   list.partners
  #   #=> [#<Partner id: 42>, #<Partner id: 11>, #<Partner id: 43>]
  #
  #   list.remove(:partners, 42)
  #   #=> [#<ListItem id: 9, item_id: 42, item_type: 'Partner'>]
  #
  #   list.remove(:partners, [11, 43])
  #   #=> [
  #   #     #<ListItem id: 91, item_id: 11, item_type: 'Partner'>,
  #   #     #<ListItem id: 17, item_id: 43, item_type: 'Partner'>
  #   #   ]
  #
  #   list.partners
  #   #=> []
  #
  # Returns a collection of the removed items.
  def remove(item_type, item_ids)
    connection.transaction do
      ListItem.where(list_id: id, item_id: item_ids).by_type(item_type).destroy_all
    end
  end

  # Concatenates the list with another.
  #
  #   list.experts
  #   #=> [#<Expert id: 12>]
  #
  #   another_list.experts
  #   #=> [#<Expert id: 44>, #<Expert id: 23>]
  #
  #   list.concat(another_list)
  #   #=> #<List id: 12>
  #
  #   list.experts
  #   #=> [#<Expert id: 12>, #<Expert id: 44>, #<Expert id: 23>]
  #
  # Returns the list.
  def concat(other)
    add_collection(other.list_items.map(&:copy))
    self
  end

  # Adds the list items to the JSON reprensentation.
  def as_json(options = {})
    super(options.merge(include: ListItem::TYPES.keys))
  end

  # Returns true if the list is public, else false.
  def public?
    ! private?
  end

  # Returns the title
  def to_s
    title.to_s
  end

  private

  # Adds a collection of potetial list items to the list.
  #
  #   list.add_collection(list.experts, Expert.where(id: [12, 13, 44])
  #   #=> [#<Expert id: 12>, #<Expert id: 13>, #<Expert id: 44>]
  #
  # Returns the collection.
  def add_collection(collection)
    connection.transaction do
      collection.each do |list_item|
        begin
          list_items << list_item
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end
  end
end
