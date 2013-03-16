# Searches the lists table.
class ListSearcher < ApplicationSearcher
  search_helpers :title, :private, :exclude

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
