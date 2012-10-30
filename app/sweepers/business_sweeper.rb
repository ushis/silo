# Observes the business model for changes and expires the business caches.
class BusinessSweeper < ActionController::Caching::Sweeper
  observe Business

  # Expires all business/select caches.
  def after_create(business)
    key = '/ajax/businesses'

    I18n.available_locales.each do |locale|
      expire_fragment("#{locale}#{key}")
      expire_fragment("#{locale}#{key}.json")
    end
  end

  alias after_update  after_create
  alias after_destroy after_create
end
