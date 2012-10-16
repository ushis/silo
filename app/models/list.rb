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
  attr_accessible :title, :private

  validates :title, presence: true, uniqueness: true

  has_and_belongs_to_many :experts,  uniq: true
  has_and_belongs_to_many :partners, uniq: true

  belongs_to :user

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

    rel
  end
end
