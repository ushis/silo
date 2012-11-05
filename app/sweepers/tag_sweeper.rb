# Observes tag like models and expires the caches.
class TagSweeper < ActionController::Caching::Sweeper
  observe Business, Adviser

  # Expires all tag related caches.
  def expire_caches_for(record)
    key = "/ajax/tags/#{record.class.name.downcase.pluralize}"

    I18n.available_locales.each do |locale|
      expire_fragment("#{locale}#{key}")
      expire_fragment("#{locale}#{key}.json")
    end
  end

  alias after_create  expire_caches_for
  alias after_update  expire_caches_for
  alias after_destroy expire_caches_for
end
