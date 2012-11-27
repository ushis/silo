# Handles list item related requests.
class ListItemsController < ApplicationController
  skip_before_filter :authorize, only: [:destroy]

  # Destroys a list item.
  def destroy
    list = List.find(params[:list_id])

    unless list.accessible_for?(current_user)
      unauthorized(lists_url)
    end

    item = list.list_items.find(params[:id])

    if item.destroy
      flash[:alert] = t('messages.list_item.success.delete', name: item.name)
    else
      flash[:notice] = t('messages.list_item.errors.delete')
    end

    redirect_to list_experts_url(list)
  end

  private

  # Sets a flash and redirects to the list.
  def not_found
    flash[:alert] = t('messages.list_item.errors.find')
    redirect_to list_experts_url(params[:list_id])
  end
end
