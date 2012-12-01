# Handles list item related requests.
class ListItemsController < ApplicationController
  skip_before_filter :authorize

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

  # Serves a csv with the lists partners including their employees.
  def employees
    list = List.find_for_user(params[:list_id], current_user)
    send_csv list.partners.as_csv(include: :employees), "#{list.title}-employees"
  end

  # Defines the actions needed to show the list items.
  ListItem::TYPES.each_key do |item_type|
    define_method(item_type) { index(item_type) }
  end

  private

  # Serves the lists items in various formats.
  def index(item_type)
    list = List.find_for_user(params[:list_id], current_user)

    respond_to do |format|
      format.html { html_index(list, item_type) }
      format.pdf  { pdf_index(list, item_type) }
      format.csv  { csv_index(list, item_type) }
    end
  end

  # Serves the lists items as html.
  def html_index(list, item_type)
    @list = list
    @title = list.title
    @item_type = item_type
    @items = list.list_items.by_type(item_type).includes(:item)
    body_class << (body_class.delete(item_type.to_s) + '-list')
    render :index
  end

  # Serves the lists items as pdf.
  def pdf_index(list, item_type)
    opt = { only: arrayified_param(:attributes) }
    send_report ListReport.new(list, item_type, current_user, opt), list.title
  end

  # Serves the lists items as csv.
  def csv_index(list, item_type)
    send_csv list.send(item_type).as_csv, "#{list.title} #{item_type}"
  end

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
