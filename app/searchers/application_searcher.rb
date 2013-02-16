require 'set'

# Base class of all searchers.
#
#   class ArticleSearcher < ApplicationSearcher
#     search_helpers :title
#
#     def title(value)
#       @scope.where('title LIKE ?', "%#{value}%")
#     end
#   end
#
#   class Article < ActiveRecord::Base
#     has_and_belongs_to_many :tags
#
#     def self.search(params)
#       ArticleSearcher.new(params.slice(:title, :tags)).search(scoped)
#     end
#
#     def self.published
#       where(published: true)
#     end
#   end
#
#   class ArticleController < ApplicationController
#     def index
#       @articles = Article.published.search(params).page(params[:page])
#     end
#   end
#
# The vanilla ApplicationSearcher can search the associated tables by
# default. Simply specify the the association name as key and an array of
# ids as value. Additional search methods must be implemented in the
# subclasses.
class ApplicationSearcher
  class_attribute :_search_helpers

  # Inits the searcher. Takes a hash of conditions.
  def initialize(conditions)
    @conditions = normalize_conditions(conditions)
  end

  # Performs the search.
  #
  # Returns a ActiveRecord::Relation.
  def search(scope)
    @scope = scope
    @klass = scope.klass
    @conditions.each { |method, value| @scope = search_for(method, value) }
    @scope
  rescue ActiveRecord::RecordNotFound
    @klass.where('1 < 0')
  end

  private

  # Registers and returns a set of search helpers.
  def self.search_helpers(*methods)
    self._search_helpers ||= Set.new
    self._search_helpers += methods
  end

  # Returns the set of registered search helpers.
  def search_helpers
    self.class.search_helpers
  end

  # Returns an array of tuples from a hash.
  #
  #   normalize_conditions("method" => "value", foo: 0, bar: '  ')
  #   #=> [[:method, "value"], [:foo, 0]]
  #
  # Blanks are removed and method names symbolized.
  def normalize_conditions(conditions)
    conditions.map do |k, v|
      [k.to_sym, v] if v.present? || v.is_a?(FalseClass)
    end.compact
  end

  # Triggers the search method and passes the query.
  #
  # Returns ActiveRecord::Relation.
  def search_for(attr, value)
    if search_helpers.include?(attr)
      send(attr, value)
    else
      search_association(attr, value)
    end
  end

  # Searches an association and returns a ActiveRecord::Relation
  #
  # Raises ArgumentError for invalid association names.
  def search_association(name, value)
    if (reflection = @klass.reflect_on_association(name))
      send(reflection.macro, reflection, value)
    else
      raise ArgumentError, "#@model has no association called #{name}"
    end
  end

  # Adds a id search condition to the relation.
  def search_ids(ids)
    if ids.empty?
      raise ActiveRecord::RecordNotFound, "Couldn't find any records."
    else
      @scope.where(@klass.primary_key => ids)
    end
  end

  # Executes some sql and returns the selected rows.
  def execute_sql(*args)
    @klass.connection.select_rows(@klass.send(:sanitize_sql, args))
  end

  # Searches a has_one association.
  def has_many(reflection, ids)
    @scope.joins(reflection.name).where(reflection.table_name => {
      reflection.association_primary_key => ids
    }).group("#{@klass.table_name}.#{@klass.primary_key}")
  end

  alias :belongs_to :has_many
  alias :has_one    :has_many

  # Searches a has_and_belongs_to_many association.
  def has_and_belongs_to_many(reflection, ids)
    search_ids(search_join_table(reflection, ids))
  end

  # Searches a join table and returns an array of ids.
  def search_join_table(reflection, ids)
    execute_sql(<<-SQL, ids: ids).map(&:first)
      SELECT join_table.#{reflection.foreign_key}
      FROM #{reflection.options[:join_table]} AS join_table
      WHERE join_table.#{reflection.association_foreign_key} IN (:ids)
      GROUP BY join_table.#{reflection.foreign_key}
    SQL
  end

  # Searches a join table conjunct and returns an array of ids.
  def search_join_table_conjunct(reflection, ids)
    execute_sql(<<-SQL, ids: ids, num: ids.length).map(&:first)
      SELECT join_table.#{reflection.foreign_key}, COUNT(*) AS num
      FROM #{reflection.options[:join_table]} AS join_table
      WHERE join_table.#{reflection.association_foreign_key} IN (:ids)
      GROUP BY join_table.#{reflection.foreign_key}
      HAVING num >= :num
    SQL
  end
end
