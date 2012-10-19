# Observes the business model for changes and expires the business caches.
class BusinessSweeper < ActionController::Caching::Sweeper
  observe Business

  # Expires all business/select caches.
  def after_create(business)
    I18n.available_locales.each do |locale|
      fragment = [locale, :businesses, :select].join('/')
      expire_fragment(fragment)
      expire_fragment("#{fragment}.json")
    end
  end

  alias after_update after_create
  alias after_destroy after_create
end
