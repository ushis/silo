# Does the same as the Ajax::LanguageController... just with users.
class Ajax::UsersController < AjaxController
  caches_action :index

  # Serves a list of all users.
  def index
    @users = User.order(:name, :prename)
    respond_with(@users)
  end
end
