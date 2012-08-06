# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController
  before_filter :authorize, except: [:index, :show]

  #
  def authorize
    unless current_user.access?(:experts)
      flash[:alert] = t('msg.access_denied')
      redirect_to experts_url
    end
  end

  #
  def show
    @expert = Expert.includes(:user).find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Serves a paginated table of all experts.
  def index
    @title = t('label.experts')
    @experts = Expert.limit(25)
  end

  # Servers a blank experts form
  def new
    @expert = Expert.new
    @title = t('label.new_expert')
    render :form
  end

  # Serves an edit form, populated with the experts data.
  def edit
    @expert = Expert.includes(:comment).find(params[:id])
    @title = t('label.edit_expert')
    render :form
  end

  def update
    @expert = Expert.includes(:comment).find(params[:id])
    @expert.user = current_user

    if (comment = params[:expert].try(:delete, :comment))
      @expert.comment.comment = comment[:comment]
    end

    @expert.attributes = params[:expert]

    if @expert.save
      flash[:notice] = t('msg.saved_changes')
      redirect_to expert_url(@expert) and return
    else
      flash.now[:alert] = t('msg.could_not_save_changes')
    end

    @title = t('label.edit_expert')
    render :form
  end

  #
  def destroy
    expert = Expert.find(params[:id])

    if expert.destroy
      flash[:notice] = t('msg.expert_deleted', expert: expert.name)
    else
      flash[:alert] = t('msg.could_not_delete_expert')
    end

  	redirect_to experts_url
  end

  #
  def not_found
    flash[:alert] = t('msg.expert_not_found')
    redirect_to experts_url
  end
end
