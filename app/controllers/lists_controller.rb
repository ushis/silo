# The ListsController provides the actions to handle some list specific
# requests. See Ajax::LitsController to find more.
class ListsController < ApplicationController
  skip_before_filter :authorize

  cache_sweeper :list_sweeper, only: :update

  # Serves all lists.
  def index
    @lists = List.search(params).accessible_for(current_user).limit(50).page(params[:page])
    @title = t('labels.list.all')
  end

  # Redirects to the current list. If the user has no current_list,
  # ListsController#not_found is triggered.
  def current
    redirect_to list_experts_url(current_list)
  rescue ActionController::RoutingError
    not_found
  end

  # Creates a new list and sets the users current list.
  def create
    list = List.new(params[:list])
    list.user = current_user
    list.current_users << current_user

    if list.save
      flash[:notice] = t('messages.list.success.create', title: list.title)
      redirect_to list_experts_url(list)
    else
      flash[:alert] = t('messages.list.errors.create')
      redirect_to lists_url
    end
  end

  # Updates a list.
  def update
    list = find_list(params[:id])
    list.attributes = params[:list]
    list.private = params[:private] if params[:private] && list.private?

    if list.save
      flash[:notice] = t('messages.list.success.save')
    else
      flash[:alert] = t('messages.list.errors.save')
    end

    redirect_to list_experts_url(list)
  end

  # Concats a list with another.
  def concat
    list = find_list(params[:id])
    list.concat(find_list(params[:other]))
    flash[:notice] = t('messages.list.success.concat')
    redirect_to list_experts_url(list)
  rescue ActiveRecord::RecordNotFound, UnauthorizedError
    raise unless list
    flash[:alert] = t('messages.list.errors.find')
    redirect_to list_experts_url(list)
  end

  # Copies a list.
  def copy
    original = find_list(params[:id])
    copy = original.copy
    copy.attributes = params[:list]
    copy.user = current_user
    copy.private = true

    if copy.save
      flash[:notice] = t('messages.list.success.copy')
      redirect_to list_experts_url(copy)
    else
      flash[:alert] = t('messages.list.errors.copy')
      redirect_to list_experts_url(original)
    end
  end

  # Destroys a list.
  def destroy
    list = find_list(params[:id])

    unless current_user.authenticate(params[:password])
      flash[:alert] = t('messages.user.errors.password')
      redirect_to list_experts_url(list) and return
    end

    if list.destroy
      flash[:notice] = t('messages.list.success.delete', title: list.title)
      redirect_to lists_url
    else
      flash[:alert] = t('messages.list.errors.delete')
      redirect_to list_experts_url(list)
    end
  end

  # Defines the actions needed to show the list items.
  ListItem::TYPES.each_key do |item_type|
    define_method(item_type) { show(item_type) }
  end

  private

  # Finds a list and raises UnauthorizedError if the current user is not
  # authorized to access it.
  def find_list(id)
    list = List.find(id)
    raise UnauthorizedError unless list.accessible_for?(current_user)
    list
  end

  # Shows the list items of a type.
  def show(item_type)
    @list = find_list(params[:list_id])
    @items = @list.list_items.by_type(item_type)
    @title = @list.title
    body_class << (body_class.delete(item_type.to_s) + '-list')
    render :show
  end

  # Sets a flash and redirects to the lists index.
  def not_found
    flash[:alert] = t('messages.list.errors.find')
    redirect_to lists_url
  end

  # Redirects to the lists index.
  def unauthorized
    super(lists_url)
  end
end
