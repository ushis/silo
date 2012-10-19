# The ListsController provides the actions to handle all list specific
# requests.
class ListsController < ApplicationController
  skip_before_filter :authorize

  layout false, only: [:select]

  #
  def index
  end

  # Serves a select box without a layout. This is an ajax action only.
  def select
    @lists = List.with_items.search(params).accessible_for(current_user).limit(20)
  end

  # Serves a list as HTML or JSON, if it is accessible for the current user.
  def show
    @list = List.find(params[:id])

    if @list.private? && @list.user_id != current_user.id
      return forbidden
    end

    respond_to do |format|
      format.html
      format.json { render json: @list }
    end
  end

  # Creates a new list and sets the users current list. Responds to HTML
  # and JSON.
  def create
    @list = List.new(params[:list])
    @list.user = current_user
    @list.current_users << current_user

    respond_to do |format|
      if @list.save
        format.html { redirect_to :show }
        format.json { render json: @list }
      else
        format.html { render :form }
        format.json { render json: t('messages.list.errors.create'), status: 422 }
      end
    end
  end

  # Sets the current list for the current user. If everything is fine, this
  # action responds with the current list as JSON.
  def use
    current_user.current_list =
      List.where(id: params[:id]).accessible_for(current_user).first

    if current_user.save
      render json: current_user.current_list
    else
      render json: t('messages.list.errors.use'), status: 422
    end
  end

  # Adds an item to the current list. This action responds with the current
  # list as JSON.
  def add
    current_user.current_list.try(:add, params[:type], params[:id])
    render json: current_user.current_list
  end

  # Removes an item from the current list. This action responds with the
  # current list as JSON.
  def remove
    current_user.current_list.try(:remove, params[:type], params[:id])
    render json: current_user.current_list
  end

  private

  # Redirects to the lists index or sends a JSON error message.
  def not_found
    respond_to do |format|
      format.html { redirect_to lists_url, alert: t('messages.list.errors.find') }
      format.json { render json: t('messages.list.errors.find'), status: 404 }
    end
  end

  # Redirects to the lists index or sends a JSON error message.
  def forbidden
    respond_to do |format|
      format.html { redirect_to lists_url, alert: t('messages.user.errors.access') }
      format.json { render json: t('messages.user.errors.access'), status: 403 }
    end
  end
end
