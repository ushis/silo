# The Ajax::ListsController handles all list specific ajax requests.
class Ajax::ListsController < AjaxController
  respond_to :html, only:   [:index, :new, :edit, :copy]
  respond_to :json, except: [:index, :new, :edit, :copy]

  caches_action :new, :edit, :copy

  # Serves a list of all lists.
  def index
    @lists = List.search(params).accessible_for(current_user)
    @title = t('labels.list.open')
    respond_with(@list)
  end

  # Shows a list.
  def show
    respond_with(find_list(params[:id]))
  end

  # Serves a list of lists for import purposes.
  def import
    @list = find_list(params[:id])
    _params = params.merge(exclude: @list)
    @lists = List.search(_params).accessible_for(current_user)
    @title = t('labels.list.import')
    render :index
  end

  # Serves an empty list form.
  def new
    @list = List.new
    @url = lists_path
    render :form
  end

  # Serves a form to edit a list.
  def edit
    @list = find_list(params[:id])
    @url = list_path(@list)
    render :form
  end

  # Serves a form to copy a list.
  def copy
    @list = find_list(params[:id])
    @url = copy_list_path(@list)
    render :form
  end

  # Creates a new list.
  def create
    list = List.new(params[:list])
    list.user = current_user
    list.current_users << current_user

    if list.save
      respond_with(list)
    else
      error(t('messages.list.errors.create'))
    end
  end

  # Opens a list.
  def open
    current_user.current_list = find_list(params[:id])

    if current_user.save
      render json: current_list
    else
      error(t('messages.list.errors.open'))
    end
  end

  # Defines needed actions the add/remove subresources to/from the list.
  ListItem::TYPES.each_key do |item_type|
    [:add, :remove].each do |op|
      define_method(:"#{op}_#{item_type}") { move(op, item_type) }
    end
  end

  private

  # Adds/Removes a subresource to/from a list.
  def move(op, item_type)
    list = find_list(params[:list_id])
    list.send(op, item_type, arrayified_param(:ids))
    render json: list
  end

  # Finds a list. Raises ActiveRecord::RecordNotFound and UnauthorizedError.
  def find_list(id)
    list = (id == 'current') ? current_list : List.find(id)
    raise ActiveRecord::RecordNotFound unless list
    raise UnauthorizedError unless list.accessible_for?(current_user)
    list
  end

  # Sets a proper error message.
  def not_found
    super(t('messages.list.errors.find'))
  end
end
