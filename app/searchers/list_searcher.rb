# Searches the lists table.
class ListSearcher < ApplicationSearcher

  # Initializes the ListSearcher. Takes a hash of conditions:
  #
  # - *:title*    To search the title column for partial matches.
  # - *:private*  Boolean to filter private/public lists.
  # - *:exclude*  An array of list ids to be excluded from the search.
  #
  # Its also takes association_name => ids as condition.
  def initialize(conditions)
    super(List, conditions)
  end

  protected

  # Searches the title.
  def title(title)
    @scope.where('lists.title LIKE ?', "%#{title}%")
  end

  # Searches the private/public lists.
  def private(value)
    @scope.where(private: value)
  end

  # Excludes lists by id.
  def exclude(ids)
    @scope.where('lists.id NOT IN (?)', ids)
  end
end
