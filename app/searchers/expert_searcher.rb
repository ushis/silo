# Searches the experts table and associations.
class ExpertSearcher < ApplicationSearcher

  # Inits the ExpertsSearcher. Takes a hash of conditions:
  #
  # - *:name*  To search name and prename for partial matches.
  # - *:q*     To perform a fulltext search.
  #
  # Also takes association names and ids.
  def initialize(conditions)
    super(Expert, conditions)
  end

  protected

  # Searches name and prename.
  def name(name)
    @scope.where('name LIKE :n OR prename LIKE :n', n: "%#{name}%")
  end

  # Searches the fulltext associations.
  def q(query)
    search_ids(search_fulltext(query))
  end

  private

  # Searches the experts fulltext associations.
  #
  # Returns an array of ids.
  def search_fulltext(query)
    sql = <<-SQL
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

    execute_sql(sql, q: query).map(&:first)
  end
end
