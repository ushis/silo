# Observes the List model for changes and expires the caches.
class ListSweeper < ActionController::Caching::Sweeper
  observe List

  # Expires the cache for the updated list.
  def after_update(list)
    expire_cache_for(list)
  end

  # Expires the cache for destroyed list.
  def after_destroy(list)
    expire_cache_for(list)
  end

  private

  # Expires the cache for the specified list.
  def expire_cache_for(list)
    I18n.available_locales.each do |locale|
      key = [locale, :ajax, :lists, list.id].join('/')
      expire_fragment(key + '/edit')
      expire_fragment(key + '/copy')
    end
  end
end
