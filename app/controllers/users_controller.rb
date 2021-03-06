# The UsersController provides CRUD actions for the users data.
#
# It is accessible as admin only.
class UsersController < ApplicationController
  before_filter :check_password,     only: [:destroy]
  before_filter :find_user,          only: [:destroy, :edit, :update]
  before_filter :block_current_user, only: [:destroy]

  # Serves a list of all users.
  #
  # GET /users
  def index
    @users = User.includes(:privilege).order('name, prename')
    @title = t('labels.user.all')
  end

  # Serves a blank user form.
  #
  # GET /users/new
  def new
    @user = User.new
    render_form(:new)
  end

  # Creates a new user and redirects to the new users edit page.
  #
  # POST /users
  def create
    @user = User.new(params[:user], as: :admin)

    if @user.save
      flash[:notice] = t('messages.user.success.create', name: @user.username)
      redirect_to users_url
    else
      flash.now[:alert] = t('messages.user.errors.create')
      render_form(:new)
    end
  end

  # Serves an edit form, populated with the users data.
  #
  # GET /users/:id/edit
  def edit
    render_form(:edit)
  end

  # Updates the users data and serves the edit form.
  #
  # PUT /users/:id
  def update
    context = current_user?(@user) ? :current_admin : :admin

    if @user.update_attributes(params[:user], as: context)
      I18n.locale = @user.locale if current_user?(@user)
      flash[:notice] = t('messages.user.success.save')
      redirect_to users_url
    else
      flash.now[:alert] = t('messages.user.errors.save')
      render_form(:edit)
    end
  end

  # Destroys a user and redirects to the users index page.
  #
  # DELETE /users/:id
  def destroy
    if @user.destroy
      flash[:notice] = t('messages.user.success.delete', name: @user.username)
    else
      flash[:alert] = t('messages.user.errors.delete')
    end

    redirect_to users_url
  end

  private

  # Finds the user
  def find_user
    @user = User.find(params[:id])
  end

  # Redirects if @user == current_user.
  def block_current_user
    unauthorized(users_url) if current_user?(@user)
  end

  # Renders the users form.
  def render_form(action)
    body_class << action
    @title = t("labels.user.#{action}")
    render :form
  end

  # Sets a "user not found" alert and redirects to the users index page.
  def not_found
    flash[:alert] = t('messages.user.errors.find')
    redirect_to users_url
  end
end
