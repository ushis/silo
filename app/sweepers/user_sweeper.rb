# Observes the User model for changes and expires the caches.
class UserSweeper < ActionController::Caching::Sweeper
  observe User

  # Expires caches when a new user was created.
  def after_create(user)
    expire_caches
  end

  # Expires caches when the name or the prename of a user was changed.
  def after_update(user)
    if user.name_changed? || user.prename_changed?
      expire_caches
    end
  end

  # Expires caches when a user was destroyed.
  def after_destroy(user)
    expire_caches
  end

  private

  # Expires all users/select caches.
  def expire_caches
    key = '/ajax/users'

    I18n.available_locales.each do |locale|
      expire_fragment("#{locale}#{key}")
    end
  end
end
