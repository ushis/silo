# The Comment model provides the ability to add comments to another model,
# just by doing something like:
#
#   class Article < ActiveRecord::Base
#     has_many :comments, as: commentable
#   end
#
# Or for has_one associations:
#
#   class Product < ActiveRecord::Base
#     is_commentable_with :comment, as: :commentable
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
#
# See the ActsAsComment module for more info.
class Comment < ActiveRecord::Base
  acts_as_comment :comment, for: :commentable, polymorphic: true
end
