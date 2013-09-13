# Searches the projects table and its associations.
class ProjectSearcher < ApplicationSearcher
  search_helpers :title, :status, :start, :end, :q

  protected

  # Searches the title attribute.
  def title(q)
    @scope.includes(:infos).where('project_infos.title LIKE ?', "%#{q}%")
  end

  # Searches the status attribute.
  def status(q)
    @scope.where(status: q)
  end

  # Searches the start attribute.
  def start(q)
    @scope.where('projects.start > ?', Date.new(q.to_i))
  end

  # Searches the end attribute.
  def end(q)
    @scope.where('projects.end < ?', Date.new(q.to_i))
  end

  # Performs a fuzzy search.
  def q(q)
    search_ids(search_fuzzy(q))
  end

  private

  # Executes the fuzzy search.
  #
  # Returns an array of partner ids.
  def search_fuzzy(query)
    execute_sql(<<-SQL, q: query, like: "%#{query}%").map(&:first)
      (
        SELECT project_infos.project_id
        FROM project_infos
        WHERE project_infos.funders LIKE :like
      ) UNION (
        SELECT partners_projects.project_id
        FROM partners_projects
        JOIN partners
        ON partners.id = partners_projects.partner_id
        WHERE partners.company LIKE :like
      ) UNION (
        SELECT project_infos.project_id
        FROM project_infos
        JOIN comments
        ON comments.commentable_id = project_infos.id
          AND comments.commentable_type = 'ProjectInfo'
        JOIN descriptions
        ON descriptions.describable_id = project_infos.id
          AND descriptions.describable_type = 'ProjectInfo'
        WHERE MATCH (comments.comment) AGAINST (:q)
          OR MATCH (descriptions.description) AGAINST (:q)
      )
    SQL
  end
end
