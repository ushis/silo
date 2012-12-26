# The ActsAsComment module defines methods making arbitrary models acting as a
# comment or being commentable, using comment like models.
#
# To make a model acting as a comment, do something like:
#
#   class Comment < ActiveRecord::Base
#     acts_as_comment :comment, for: :commentable, polymorphic: true
#   end
#
# To determine if a model acts as a comment, use the class method
# acts_as_comment?.
#
#   Comment.acts_as_comment?  #=> true
#
# With the :for option is it possible to initialize a belongs_to
# relationship to another model:
#
#   class Text < ActiveRecord::Base
#     acts_as_comment :text, for: :book
#   end
#
# The above has the same effect as:
#
#   class Text < ActiveRecord::Base
#     acts_as_comment :text
#     belongs_to :book
#   end
#
# Every comment like model has the method to_s, returning the comment.
#
#   Comment.new(comment: 'Hello World').to_s  #=> 'Hello World'
#
# Another remarkable behavior is, that the commentable attribute is
# initialized with an empty string, when empty.
#
#   Comment.new.comment  #=> ''
#
# This is not very fancy. To make it useful, take a second model and define it
# as commentable.
#
#   class Product < ActiveRecord::Base
#     is_commentable_with :comment, as: :commentable
#   end
#
# Now the comment behaves like an attribute of the product model:
#
#   product.comment = 'Hello World'
#   product.comment       #=> #<Comment id: 12, comment: 'Hello World'>
#   product.comment.to_s  #=> 'Hello World'
#
# ==== SECURITY NOTE:
#
# Every association used with is_commentable_with is white listed for
# mass assignment using attr_accessible. This is nice, if you want to do
# things like:
#
#   Product.new(name: 'Keyboard', comment: 'The keys are very loud.')
#
# But can be a problem in some situations.
module ActsAsComment
end

require 'acts_as_comment/not_a_comment'
require 'acts_as_comment/acts_as_comment'
require 'acts_as_comment/is_commentable_with'
