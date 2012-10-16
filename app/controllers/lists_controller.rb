#
class ListsController < ApplicationController
  skip_before_filter :authorize

  layout false, only: [:select]

  #
  def index
  end

  #
  def select
    @lists = List.search(params).limit(20).order(:title)

    respond_to do |format|
      format.html
      format.json { render json: @lists }
    end
  end

  # FIXME
  def use
    current_user.current_list = List.find_by_id(params[:id])

    respond_to do |format|
      if current_user.save
        format.json { render json: current_user.current_list }
      end
    end
  end
end
