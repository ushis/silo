# Handles list item related requests.
class ListItemsController < ApplicationController
  before_filter :find_list

  skip_before_filter :authorize

  # Destroys a list item.
  #
  # DELETE /lists/:list_id/list_items/:id
  def destroy
    item = @list.list_items.find(params[:id])

    if item.destroy
      flash[:alert] = t('messages.list_item.success.delete', name: item.name)
    else
      flash[:notice] = t('messages.list_item.errors.delete')
    end

    redirect_to :back
  end

  # Serves a csv with the lists partners including their employees.
  #
  # GET /lists/:list_id/employees
  def employees
    send_csv @list.partners.as_csv(include: :employees), "#{@list.title}-employees"
  end

  # Defines the actions needed to show the list items.
  #
  # GET /lists/:list_id/experts
  # GET /lists/:list_id/partners
  ListItem::TYPES.each_key do |item_type|
    define_method(item_type) { index(item_type) }
  end

  private

  # Serves the lists items in various formats.
  def index(item_type)
    respond_to do |format|
      format.html { html_index(item_type) }
      format.pdf  { pdf_index(item_type) }
      format.csv  { csv_index(item_type) }
    end
  end

  # Serves the lists items as html.
  def html_index(item_type)
    @title = @list.title
    @item_type = item_type
    @items = @list.list_items.by_type(item_type).includes(:item)
    body_class << (body_class.delete(item_type.to_s) + '-list')
    render :index
  end

  # Serves the lists items as pdf.
  def pdf_index(item_type)
    opt = { only: arrayified_param(:attributes) }
    send_report ListReport.new(@list, item_type, current_user, opt)
  end

  # Serves the lists items as csv.
  def csv_index(item_type)
    send_csv @list.send(item_type).as_csv, "#{@list.title} #{item_type}"
  end

  # Finds the list.
  def find_list
    @list = current_user.accessible_lists.find(params[:list_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.list.errors.find')
    redirect_to lists_url
  end

  # Sets a flash and redirects to the list.
  def not_found
    flash[:alert] = t('messages.list_item.errors.find')
    redirect_to list_experts_url(params[:list_id])
  end
end
