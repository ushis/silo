# Observes the Employee model for changes and expires the caches.
class EmployeeSweeper < ActionController::Caching::Sweeper
  observe Employee

  # Expires the cache for the updated employee.
  def after_update(employee)
    expire_cache_for(employee)
  end

  # Expires the cache for destroyed employee.
  def after_destroy(employee)
    expire_cache_for(employee)
  end

  private

  # Expires the cache for the specified employee.
  def expire_cache_for(employee)
    key = "/ajax/partners/#{employee.partner.try(:id)}/employees/#{employee.id}/edit"

    I18n.available_locales.each do |locale|
      expire_fragment("#{locale}#{key}")
    end
  end
end
