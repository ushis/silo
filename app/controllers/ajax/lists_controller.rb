# The Ajax::ListsController handles all list specific ajax requests.
class Ajax::ListsController < AjaxController
  before_filter :find_list, only: [:show, :import, :edit, :copy, :open]

  respond_to :html, only:   [:index, :new, :edit, :copy, :print]
  respond_to :json, except: [:index, :new, :edit, :copy, :print]

  caches_action :new, :edit, :copy, :print

  # Serves a list of all lists.
  #
  # GET /ajax/lists
  def index
    @lists = current_user.accessible_lists.search(params)
    @title = t('labels.list.open')
    respond_with(@list)
  end

  # Shows a list.
  #
  # GET /ajax/lists/:id
  def show
    respond_with(@list)
  end

  # Serves a list of lists for import purposes.
  #
  # GET /ajax/lists/import
  def import
    @lists = current_user.accessible_lists.search(params.merge(exclude: @list))
    @title = t('labels.list.import')
    render :index
  end

  # Serves an empty list form.
  #
  # GET /ajax/lists/new
  def new
    @list = List.new
    @url = lists_path
    render :form
  end

  # Serves a form to edit a list.
  #
  # GET /ajax/lists/:id/edit
  def edit
    @url = list_path(@list)
    render :form
  end

  # Serves a form to copy a list.
  #
  # GET /ajax/lists/:id/copy
  def copy
    @url = copy_list_path(@list)
    render :form
  end

  # Opens a list.
  #
  # PUT /ajax/lists/:id/open
  def open
    current_user.current_list = @list

    if current_user.save
      render json: current_list
    else
      error(t('messages.list.errors.open'))
    end
  end

  private

  # Finds the list.
  def find_list
    if params[:id] == 'current'
      @list = current_list!
    else
      @list = current_user.accessible_lists.find(params[:id])
    end
  end

  # Sets a proper error message.
  def not_found
    super(t('messages.list.errors.find'))
  end
end
