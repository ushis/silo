# Searches the partners table and its associations.
class PartnerSearcher < ApplicationSearcher
  search_helpers :company, :q

  protected

  # Searches the company attribute.
  def company(company)
    @scope.where('company LIKE ?', "%#{company}%")
  end

  # Performs a fuzzy search.
  def q(query)
    search_ids(search_fuzzy(query))
  end

  private

  # Executes the fuzzy search.
  #
  # Returns an array of partner ids.
  def search_fuzzy(query)
    execute_sql(<<-SQL, q: query, like: "%#{query}%").map(&:first)
      (
        SELECT partners.id
        FROM partners
        WHERE partners.street LIKE :like
          OR partners.zip LIKE :like
          OR partners.city LIKE :like
          OR partners.region LIKE :like
      ) UNION (
        SELECT employees.partner_id
        FROM employees
        WHERE employees.prename LIKE :like
          OR employees.name LIKE :like
      ) UNION (
        SELECT advisers_partners.partner_id
        FROM advisers_partners
        JOIN advisers
        ON advisers.id = advisers_partners.adviser_id
        WHERE advisers.adviser LIKE :like
      ) UNION (
        SELECT comments.commentable_id
        FROM comments
        WHERE comments.commentable_type = 'Partner'
          AND MATCH (comments.comment) AGAINST (:q)
      ) UNION (
        SELECT descriptions.describable_id
        FROM descriptions
        WHERE descriptions.describable_type = 'Partner'
          AND MATCH (descriptions.description) AGAINST (:q)
      )
    SQL
  end
end
