# The Ajax::ListsController handles all list specific ajax requests.
class Ajax::ListsController < AjaxController
  respond_to :html, only:   [:index, :new, :edit, :copy]
  respond_to :json, except: [:index, :new, :edit, :copy]

  # Serves a list of all lists.
  def index
    @lists = List.search(params).accessible_for(current_user).limit(20)
    respond_with(@list)
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

  # Shows a list.
  def show
    respond_with(find_list(params[:id]))
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
  [:experts, :partners].each do |resource|
    [:add, :remove].each do |op|
      define_method(:"#{op}_#{resource}") { move(op, resource) }
    end
  end

  private

  # Adds/Removes a subresource to/from a list.
  def move(op, resource)
    list = find_list(params[:list_id])
    list.send(op, resource, params[:id])
    render json: list
  end

  # Finds a list. Raises ActiveRecord::RecordNotFound and UnauthorizedError.
  def find_list(id)
    unless (list = (id == 'current') ? current_list : List.find_by_id(id))
      raise ActiveRecord::RecordNotFound
    end

    unless list.accessible_for?(current_user)
      raise UnauthorizedError
    end

    list
  end

  # Sets a proper error message.
  def not_found
    super(t('messages.list.errors.find'))
  end
end
