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

  # Serves a paginated table of all experts.
  def index
    @experts = Expert.includes(:cvs).limit(50).page(params[:page])
    @title = t('label.experts')
  end

  #
  def show
    @expert = Expert.includes(:user).find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Servers a blank experts form
  def new
    @expert = Expert.new
    @title = t('label.new_expert')
    render :form
  end

  # Creates a new expert and redirects to the experts details page on success.
  def create
    comment = params[:expert].try(:delete, :comment)

    @expert = Expert.new(params[:expert])
    @expert.user = current_user
    @expert.comment.comment = comment[:comment] if comment

    if @expert.save
      flash[:notice] = t('msg.created_expert', name: @expert.name)
      redirect_to expert_url(@expert) and return
    else
      flash[:alert] = t('msg.could_not_create_expert')
    end

    @title = t('label.new_expert')
    render :form
  end

  # Serves an edit form, populated with the experts data.
  def edit
    @expert = Expert.includes(:comment).find(params[:id])
    @title = t('label.edit_expert')
    render :form
  end

  # Updates an expert and redirects to the experts details page on success.
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
      flash[:notice] = t('msg.deleted_expert', expert: expert.name)
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
