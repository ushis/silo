# The UsersController provides CRUD actions for the users data. It is
# accessibles as admin only. Exceptions are the methods _profile_ and
# _update_profile_.
class UsersController < ApplicationController
  before_filter :authorize, except: [:profile, :update_profile]

  # Checks the user for admin privileges and redirects to the root url,
  # if he/she is no admin.
  def authorize
    unless current_user.admin?
      flash[:alert] = t(:msg_access_prohibited)
      redirect_to root_url
    end
  end

  # Serves the users profile. Admins are redirected to their edit page.
  def profile
    if current_user.admin?
      redirect_to edit_user_url(current_user)
    end

    @title = t(:label_profile)
    @user = current_user
  end

  # Updates a users profile. If a user wants to change his(her password, the
  # old password is required.
  def update_profile
    @title = t(:label_profile)
    @user = current_user
    password_old = params[:user].delete(:password_old)
    @user.attributes = params[:user]

    if ! params[:user][:password].blank? && ! @user.authenticate(password_old)
      flash.now[:alert] = t(:msg_could_not_save_changes)
      @user.errors.add(:password_old, t(:msg_wrong_password))
    elsif @user.save
      flash.now[:notice] = t(:msg_saved_changes)
    else
      flash.now[:alert] = t(:msg_could_not_save_changes)
    end

    render :profile
  end

  # Serves a list of all users.
  def index
    @title = t(:label_all_users)
    @users = User.order('name, prename')
  end

  # Servers a blank user form.
  def new
    @title = t(:label_new_user)
    @user = User.new
    @user.privilege = Privilege.new
    render :form
  end

  # Creates a new user and redirects to the new users edit page.
  def create
    username = params[:user].delete(:username)
    @user = User.new(params[:user])
    @user.username = username
    @user.privileges = params[:privilege]

    if @user.save
      flash[:notice] = t(:msg_created_user, user: @user.username)
      redirect_to edit_user_url(@user)
    else
      @title = t(:label_new_user)
      flash.now[:alert] = t(:msg_could_not_create_user)
      render :form
    end
  end

  # Serves an edit form, populated with the users data.
  def edit
    @title = t(:label_edit_user)
    @user = User.find(params[:id])
    render :form
  end

  # Updates the users data and serves the edit form.
  #
  # *Note:* A user can not change his/her own privileges.
  def update
    @title = t(:label_edit_user)
    @user = User.find(params[:id])

    username = params[:user].delete(:username)
    @user.attributes = params[:user]
    @user.username = username

    if @user != current_user
      @user.privileges = params[:privilege]
    end

    if @user.save
      flash.now[:notice] = t(:msg_saved_changes)
    else
      flash.now[:alert] = t(:msg_could_not_save_changes)
    end

    render :form
  end

  # Destroys a user and redirects to the users index page.
  #
  # *Note:* A user can not destroy him/herself.
  def destroy
    user = User.find(params[:id])

    if user == current_user
      flash[:alert] = t(:msg_delete_current_user_error)
      redirect_to users_url and return
    end

    unless user.destroy
      flash[:alert] = t(:msg_could_not_delete_user)
    else
      flash[:notice] = t(:msg_deleted_user, user: user.username)
    end

    redirect_to users_url
  end

  # Sets a "user not found" alert and redirects to the users index page.
  def not_found
    flash[:alert] = t(:msg_user_not_found)
    redirect_to users_url
  end
end
