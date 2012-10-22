# The ListsController provides the actions to handle all list specific
# requests.
class ListsController < ApplicationController
  skip_before_filter :authorize

  layout false, only: [:select]

  # Serves all lists.
  def index
    @lists = List.accessible_for(current_user).limit(50).page(params[:page])
    @title = t('labels.list.all')
  end

  # Searches for a list.
  def search
    @lists = List.search(params).accessible_for(current_user).limit(50).page(params[:page])
    @title = t('labels.list.search')
    body_class << :index
    render :index
  end

  # Serves a select box without a layout. This is an ajax action only.
  def select
    @lists = List.search(params).accessible_for(current_user).limit(20)
  end

  # Serves the current list.
  def current
    show(current_list)
  end

  # Serves a list.
  def experts
    body_class << (body_class.delete(params[:action]) + '-list')
    show(List.find(params[:list_id]))
  end

  alias partners experts

  # Creates a new list and sets the users current list. Responds to HTML
  # and JSON.
  def create
    @list = List.new(params[:list])
    @list.user = current_user
    @list.current_users << current_user

    respond_to do |format|
      if @list.save
        format.html { redirect_to list_experts_url(@list) }
        format.json { render json: @list }
      else
        format.html { redirect_to lists_url, alert: t('messages.list.erros.create') }
        format.json { render json: t('messages.list.errors.create'), status: 422 }
      end
    end
  end

  # Destroys a list.
  def destroy
    list = List.find(params[:id])

    unless list.accessible_for?(current_user)
      return forbidden
    end

    unless current_user.authenticate(params[:password])
      flash[:alert] = t('messages.user.errors.password')
      redirect_to list_url(list) and return
    end

    if list.destroy
      flash[:notice] = t('messages.list.success.destroy', title: list.title)
      redirect_to lists_url
    else
      flash[:alert] = t('messages.list.errors.destroy')
      redirect_to list_url(list)
    end
  end

  # Sets the current list for the current user. If everything is fine, this
  # action responds with the current list as JSON.
  def open
    current_user.current_list =
      List.where(id: params[:id]).accessible_for(current_user).first

    if current_user.save
      render json: current_list
    else
      render json: t('messages.list.errors.use'), status: 422
    end
  end

  # Adds an item to the current list.
  def add
    move(:add)
  end

  # Removes an item from the current list.
  def remove
    move(:remove)
  end

  private

  # Serves a list as HTML or JSON, if it is accessible for the current user.
  def show(list)
    @list = list
    @title = @list.try(:title)

    if @list && ! @list.accessible_for?(current_user)
      return forbidden
    end

    respond_to do |format|
      format.html
      format.json { render json: @list }
    end
  end

  # Adds/Removes an item to/from a list. Responds with a JSON representation
  # of the list or redirects the user.
  def move(op)
    id, item_type, item_id = params.values_at(:list_id, :type, :id)
    list = id ? List.find(id) : current_list

    if list && ! list.accessible_for?(current_user)
      return forbidden
    end

    list.try(op, item_type, item_id)

    respond_to do |format|
      format.html { redirect_to((list && available_action?(item_type)) ?
                                { action: item_type, id: list } : lists_url) }
      format.json { render json: list }
    end
  end

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
