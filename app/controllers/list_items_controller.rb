# Handles list item related requests.
class ListItemsController < ApplicationController
  skip_before_filter :authorize, only: [:destroy]

  # Destroys a list item.
  def destroy
    list = List.find_for_user(params[:list_id], current_user)
    item = list.list_items.find(params[:id])

    if item.destroy
      flash[:alert] = t('messages.list_item.success.delete', name: item.name)
    else
      flash[:notice] = t('messages.list_item.errors.delete')
    end

    redirect_to :back
  end

  private

  # Sets a flash and redirects to the lists index.
  def unauthorized
    super(lists_url)
  end

  # Sets a flash and redirects to the list.
  def not_found
    flash[:alert] = t('messages.list_item.errors.find')
    redirect_to list_experts_url(params[:list_id])
  end
end
