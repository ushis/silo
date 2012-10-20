# Observes the User model for changes and expires the caches.
class UserSweeper < ActionController::Caching::Sweeper
  observe User

  # Expires all users/select caches.
  def after_create(user)
    I18n.available_locales.each do |locale|
      expire_fragment([locale, :users, :select].join('/'))
    end
  end

  alias after_update after_create
  alias after_destroy after_create
end
