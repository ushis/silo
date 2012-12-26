# Tha ActsAsTag module defines methods making arbitrary models acting as
# tags or taggable, using the tag like models as associations.
#
# To make a model acting as a tag, you can do something like:
#
#   class KeyWord < ActiveRecord::Base
#     acts_as_tag :word  # :word is a database column.
#   end
#
# Every tag like model has a from_s method, extracting tags from a string. The
# default seperator is a comma, but can be overriden by a second argument.
#
#   KeyWord.from_s('Programming, Ruby, CoffeeScript')
#   #=> [
#   #     #<KeyWord id: 12,  word: 'Programming'>,
#   #     #<KeyWord id: 44,  word: 'Ruby'>,
#   #     #<KeyWord id: nil, word: 'CoffeeScript'>
#   #   ]
#
# Another method that is available for tag like models is to_s, returning the
# specified attribute:
#
#   KeyWord.find(44).to_s  #=> 'Ruby'
#
# To determine if a model acts as a tag, use:
#
#   KeyWord.acts_as_tag?  #=> true
#
# This is pretty nice. To make it awesome, use a second model and define it as
# taggable:
#
#   class Article < ActiveRecord::Base
#     is_taggable_with :key_words
#   end
#
# Now it is possible to use it like this:
#
#   article = Article.last
#
#   article.key_words = 'Ruby, CSS , JavaScript'
#   #=> [
#   #     #<KeyWord id: 44, word: 'Ruby'>,
#   #     #<KeyWord id: 89, word: 'CSS'>,
#   #     #<KeyWord id: 90, word: 'JavaScript'>
#   #   ]
#
#   article.key_words.join(', ')
#   #=> 'Ruby, CSS, JavaScript'
#
# ==== SECURITY NOTE:
#
# Every association used with is_taggable_with is white listed for
# mass assignment using attr_accessible. This is very useful, if
# you want to do something like this:
#
#   Article.new(title: 'Hello World', key_words: 'Ruby, CSS, SQL')
#
# But can be a problem in some cases.
module ActsAsTag
end

require 'acts_as_tag/not_a_tag'
require 'acts_as_tag/acts_as_tag'
require 'acts_as_tag/is_taggable_with'
