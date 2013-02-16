# Searches the experts table and associations.
class ExpertSearcher < ApplicationSearcher
  search_helpers :name, :q, :languages

  protected

  # Searches name and prename.
  def name(name)
    @scope.where('name LIKE :n OR prename LIKE :n', n: "%#{name}%")
  end

  # Searches the fulltext associations.
  def q(query)
    search_ids(execute_sql(<<-SQL, q: query).map(&:first))
      (
        SELECT comments.commentable_id AS expert_id
        FROM comments
        WHERE comments.commentable_type = 'Expert'
          AND MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE)
      ) UNION (
        SELECT cvs.expert_id
        FROM cvs
        WHERE MATCH (cvs.cv) AGAINST (:q IN BOOLEAN MODE)
      )
    SQL
  end

  # Search languages conjunct.
  def languages(value)
    search_ids(search_join_table_conjunct(
      @klass.reflect_on_association(:languages), value))
  end
end
