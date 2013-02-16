# Handles list item related ajax requests.
class Ajax::ListItemsController < Ajax::ApplicationController
  before_filter :find_list, except: [:print]

  skip_before_filter :authorize, only: [:update]

  respond_to :json, only: [:update]

  # Updates the list item.
  #
  # PUT /lists/:list_id/list_items/:id
  def update
    item = @list.list_items.find(params[:id])

    if item.update_attributes(params[:list_item])
      render json: item
    else
      error(t('messages.list_item.errors.update'))
    end
  end

  # Defines needed actions the print/add/remove list items.
  #
  # GET    /ajax/lists/:list_id/{item_type}/print
  # POST   /ajax/lists/:list_id/{item_type}
  # DELETE /ajax/lists/:list_id/{item_type}
  ListItem::TYPES.each_key do |item_type|
    [:print, :create, :destroy].each do |action|
      define_method("#{action}_#{item_type}") { send(action, item_type) }
    end
  end

  private

  # Serves a print dialog.
  def print(item_type)
    @item_type = item_type
    render :print
  end

  # Creates list items.
  def create(item_type)
    @list.add(item_type, arrayified_param(:ids))
    render json: @list
  end

  # Destroys list items.
  def destroy(item_type)
    @list.remove(item_type, arrayified_param(:ids))
    render json: @list
  end

  # Finds the list.
  def find_list
    if params[:list_id] == 'current'
      @list = current_list!
    else
      @list = current_user.accessible_lists.find(params[:list_id])
    end
  end

  # Sets a proper not found error message.
  def not_found
    super(t('messages.list_item.errors.find'))
  end
end
