# Handles list item related ajax requests.
class Ajax::ListItemController < AjaxController
  skip_before_filter :authorize, only: [:update]

  respond_to :json, only: [:update]

  # Updates the list item.
  def update
    list = List.find_for_user(params[:list_id], current_user)
    item = list.list_items.find(params[:id])

    if item.update_attributes(params[:list_item])
      render json: item
    else
      error(t('messages.list_item.errors.update'))
    end
  end

  private

  # Sets a proper not found error message.
  def not_found
    super(t('messages.list_item.errors.find'))
  end
end
