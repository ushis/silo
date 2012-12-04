require 'set'

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
# Its is also possible to find records, that are associated with specific tags:
#
#   # Some key word ids from else where.
#   key_word_ids = [12, 67, 24, 11]
#
#   # Find articles, that are associated with all of the specified key words.
#   Article.search_key_words(key_word_ids)  #=> [3, 12, 44]
#
# ==== SECURITY NOTE:
#
# Every association used with is_taggable_on is white listed for
# mass assignment using attr_accessible. This is very useful, if
# you want to do something like this:
#
#   Article.new(title: 'Hello World', key_words: 'Ruby, CSS, SQL')
#
# But can be a problem in some cases.
module ActsAsTag
  extend ActiveSupport::Concern

  # Defines the magic methods ClassMethods#acts_as_tag and
  # ClassMethods#is_taggable_with.
  module ClassMethods

    # Makes a model acting like a tag. See the ActsAsTag module for further
    # description.
    def acts_as_tag(attribute_name)
      attr_accessible(attribute_name)
      validates(attribute_name, presence: true, uniqueness: true)
      default_scope(order(attribute_name))

      # Defines the Model.from_s method to extract tags from a string.
      define_singleton_method(:from_s) do |s, delimiter = /\s*,\s*/|
        results = s.split(delimiter).inject(Set.new) do |set, tag|
          tag.blank? ? set : set << tag.strip
        end

        results.empty? ? [] : multi_find_or_initialize(results.to_a)
      end

      search_sql = "LOWER(#{attribute_name}) IN (?)"

      # Defines the Model.multi_find_or_initialize method to find existing
      # and initialize new tags.
      define_singleton_method(:multi_find_or_initialize) do |tags|
        results = where(search_sql, tags.map(&:downcase)).each do |tag|
          tags.delete_if { |t| t.casecmp(tag.to_s) == 0 }
        end

        results + tags.map { |tag| new(attribute_name => tag) }
      end

      # Defines Model.acts_as_tag?
      define_singleton_method(:acts_as_tag?) { true }

      # Defines Model#to_s
      define_method(:to_s) { send(attribute_name).to_s }
    end

    # Makes a model taggable by adding tag like models to the list of
    # associations. See the ActsAsTag module for further description.
    def is_taggable_with(*associations)
      associations.each do |assoc|
        assoc_class = assoc.to_s.classify.constantize

        unless assoc_class.respond_to?(:acts_as_tag?) && assoc_class.acts_as_tag?
          raise ArgumentError, "Association is not taggable: #{assoc}"
        end

        attr_accessible(assoc)

        reflection = has_and_belongs_to_many(assoc, uniq: true)

        search_sql = <<-SQL
          SELECT #{reflection.foreign_key}, COUNT(*) AS num
          FROM #{reflection.options[:join_table]}
          WHERE #{reflection.association_foreign_key} IN (:ids)
          GROUP BY #{reflection.foreign_key}
          HAVING num >= :num
        SQL

        # Defines Model.search_tags()
        #
        # Takes an Array of tag ids and returns ids of taggable models, that
        # are associated with all of the specified tags.
        define_singleton_method(:"search_#{assoc}") do |ids|
          connection.select_rows(sanitize_sql(
            [search_sql, ids: ids, num: ids.length]
          )).map(&:first)
        end

        # Defines the tags writer method to handle strings containing tags.
        define_method(:"#{assoc}=") do |tags|
          super(tags.is_a?(String) ? assoc_class.from_s(tags) : tags)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsTag
