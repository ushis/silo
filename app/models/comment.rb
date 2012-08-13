# The Comment model provides the ability to add comments to another model,
# just by doing something like:
#
#   class Article < ActiveRecord::Base
#     has_many :comments, as: commentable
#   end
#
# The comment is saved in the _comment_ attribute.
#
# Database scheme:
#
# - *id* integer
# - *commentable_id* integer
# - *commentable_type* string
# - *comment* text
# - *created_at* datetime
# - *updated_at* datetime
class Comment < ActiveRecord::Base
  attr_accessible :comment

  after_initialize :init_comment

  belongs_to :commentable, polymorphic: true

  # Adds a fulltext search condition to the query.
  #
  # Returns ActiveRecord::Relation.
  def self.search(query)
    where('MATCH (comments.comment) AGAINST (?)', query)
  end

  # Initializes the comment with an empty string.
  def init_comment
    self.comment ||= ''
  end

  # Returns the comment.
  def to_s
    comment
  end
end
