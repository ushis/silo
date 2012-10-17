#
class ListsController < ApplicationController
  skip_before_filter :authorize

  layout false, only: [:select, :use]

  respond_to :html, :json

  #
  def index
  end

  #
  def select
    @lists = List.search(params).limit(20).order(:title)
    respond_with(@lists)
  end

  #
  def use
    current_user.current_list = List.find_by_id(params[:id])

    if current_user.save
      render json: current_user.current_list
    else
      respond_with(t('messages.list.errors.use'), status: 422)
    end
  end

  def create
    @list = List.new(params[:list])
    @list.user = current_user
    @list.current_users << current_user

    if @list.save
      respond_with(@list)
    else
      respond_with(t('messages.list.errors.create'), status: 422)
    end
  end
end
