# The UsersController provides CRUD actions for the users data. It is
# accessibles as admin only. Exceptions are the methods _profile_ and
# _update_profile_.
class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:profile, :update_profile]

  # Serves the users profile. Admins are redirected to their edit page.
  def profile
    redirect_to edit_user_url(current_user) if current_user.admin?

    @user = current_user
    @title = t('labels.user.profile')
    @body_class << :edit
  end

  # Updates a users profile. If a user wants to change his(her password, the
  # old password is required.
  def update_profile
    password_old = params[:user].delete(:password_old)

    @user = current_user
    @user.attributes = params[:user]

    if ! params[:user][:password].blank? && ! @user.authenticate(password_old)
      flash.now[:alert] = t('messages.generics.errors.save')
      @user.errors.add(:password_old, t('messages.user.errors.password'))
    elsif @user.save
      I18n.locale = @user.locale
      flash.now[:notice] = t('messages.user.success.save')
    else
      flash.now[:alert] = t('messages.user.errors.save')
    end

    @title = t('labels.user.profile')
    @body_class << :edit
    render :profile
  end

  # Serves a list of all users.
  def index
    @users = User.order('name, prename')
    @title = t('labels.user.all')
  end

  # Serves a blank user form.
  def new
    @user = User.new
    @title = t('title.user.all')
    render :form
  end

  # Creates a new user and redirects to the new users edit page.
  def create
    username = params[:user].delete(:username)

    @user = User.new(params[:user])
    @user.username = username
    @user.privileges = params[:privilege]

    if @user.save
      flash[:notice] = t('messages.user.success.create', name: @user.username)
      redirect_to users_url and return
    end

    @title = t('labels.user.new')
    flash.now[:alert] = t('messages.user.errors.create')
    @body_class << :new
    render :form
  end

  # Serves an edit form, populated with the users data.
  def edit
    @user = User.find(params[:id])
    @title = t('labels.user.edit')
    render :form
  end

  # Updates the users data and serves the edit form.
  #
  # *Note:* A user can not change his/her own privileges.
  def update
    username = params[:user].delete(:username)

    @user = User.find(params[:id])
    @user.attributes = params[:user]
    @user.username = username

    if @user != current_user
      @user.privileges = params[:privilege]
    end

    if @user.save
      flash[:notice] = t('messages.user.success.save')
      redirect_to users_url and return
    end

    flash.now[:alert] = t('messages.user.errors.save')
    @title = t('labels.user.edit')
    @body_class << :edit
    render :form
  end

  # Destroys a user and redirects to the users index page.
  #
  # *Note:* A user can not destroy him/herself.
  def destroy
    user = User.find(params[:id])

    if user == current_user
      flash[:alert] = t('messages.user.errors.delete_current_user')
      redirect_to users_url and return
    end

    if user.destroy
      flash[:notice] = t('messages.deleted_user', user: user.username)
    else
      flash[:alert] = t('messages.user.errors.delete')
    end

    redirect_to users_url
  end

  # Sets a "user not found" alert and redirects to the users index page.
  def not_found
    flash[:alert] = t('messages.user.errors.find')
    redirect_to users_url
  end
end
