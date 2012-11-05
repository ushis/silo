# The UsersController provides CRUD actions for the users data. It is
# accessibles as admin only. Exceptions are the methods
# UsersController#profile and UsersController#update_profile.
class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:profile, :update_profile]

  # Serves the users profile. Admins are redirected to their edit page.
  def profile
    if current_user.admin?
      redirect_to edit_user_url(current_user) and return
    end

    @user = current_user
    @title = t('labels.user.profile')
    body_class << :edit
  end

  # Updates a users profile. If a user wants to change his(her password, the
  # old password is required.
  def update_profile
    @title = t('labels.user.profile')
    body_class << :edit

    password = params[:user].try(:delete, :password)
    password_old = params[:user].try(:delete, :password_old)

    @user = current_user
    @user.attributes = params[:user]

    if ! password.blank? && ! @user.authenticate(password_old)
      @user.errors.add(:password_old, t('messages.user.errors.password'))
      flash.now[:alert] = t('messages.generics.errors.save')
      render :profile and return
    end

    @user.password = password

    if @user.save
      I18n.locale = @user.locale
      flash.now[:notice] = t('messages.generics.success.save')
    else
      flash.now[:alert] = t('messages.generics.errors.save')
    end

    render :profile
  end

  # Serves a list of all users.
  def index
    @users = User.includes(:privilege).order('name, prename')
    @title = t('labels.user.all')
  end

  # Serves a blank user form.
  def new
    @user = User.new
    @title = t('labels.user.new')
    render :form
  end

  # Creates a new user and redirects to the new users edit page.
  def create
    username = params[:user].try(:delete, :username)
    privileges = params[:user].try(:delete, :privilege)

    @user = User.new(params[:user])
    @user.username = username
    @user.privileges = privileges

    if @user.save
      flash[:notice] = t('messages.user.success.create', name: @user.username)
      redirect_to users_url and return
    end

    flash.now[:alert] = t('messages.user.errors.create')
    @title = t('labels.user.new')
    body_class << :new
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
    username = params[:user].try(:delete, :username)
    privileges = params[:user].try(:delete, :privilege)

    @user = User.find(params[:id])
    @user.attributes = params[:user]
    @user.username = username

    unless current_user?(@user)
      @user.privileges = privileges
    end

    if @user.save
      I18n.locale = @user.locale if current_user?(@user)
      flash[:notice] = t('messages.user.success.save')
      redirect_to users_url and return
    end

    flash.now[:alert] = t('messages.user.errors.save')
    @title = t('labels.user.edit')
    body_class << :edit
    render :form
  end

  # Destroys a user and redirects to the users index page.
  #
  # *Note:* A user can not destroy him/herself.
  def destroy
    user = User.find(params[:id])

    unless current_user.authenticate(params[:password])
      flash[:alert] = t('messages.user.errors.password')
      redirect_to users_url and return
    end

    if user == current_user
      flash[:alert] = t('messages.user.errors.delete_current_user')
      redirect_to users_url and return
    end

    if user.destroy
      flash[:notice] = t('messages.user.success.delete', name: user.username)
    else
      flash[:alert] = t('messages.user.errors.delete')
    end

    redirect_to users_url
  end

  private

  # Sets a "user not found" alert and redirects to the users index page.
  def not_found
    flash[:alert] = t('messages.user.errors.find')
    redirect_to users_url
  end
end
