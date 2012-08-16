require 'prawn'

# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show, :contact, :documents, :report]

  # Checks if the user has access to the experts section.
  def authorize
    super(:experts, experts_url)
  end

  # Serves a paginated table of all experts.
  def index
    @experts = Expert.includes(:cvs, :attachments).limit(50).page(params[:page]).order(:name)
    @title = t('label.experts')
  end

  # Searches for experts.
  def search
    @experts = Expert.includes(:cvs, :attachments).search(params).limit(50).page(params[:page])
    @title = t('label.experts')
    render :index
  end

  # Serves the experts details page.
  def show
    @expert = Expert.includes(:user, :comment, :languages).find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Serves an addresses and contacts page.
  def contact
    @expert = Expert.includes(:addresses, :contact).find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Serves the experts documents page.
  def documents
    @expert = Expert.includes(:attachments, :cvs, :user).find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Sends a generated pdf including the experts deatils.
  def report
    e = Expert.includes(:contact).find(params[:id])
    send_data ExpertsReport.for_expert(e).render,
              filename: "report-#{e.full_name.parameterize}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
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
    @expert.languages = params[:languages]

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
    @expert = Expert.includes(:comment, :languages).find(params[:id])
    @title = t('label.edit_expert')
    render :form
  end

  # Updates an expert and redirects to the experts details page on success.
  def update
    @expert = Expert.includes(:comment, :languages).find(params[:id])
    @expert.user = current_user

    if (comment = params[:expert].try(:delete, :comment))
      @expert.comment.comment = comment[:comment]
    end

    @expert.attributes = params[:expert]
    @expert.languages = params[:languages]

    if @expert.save
      flash[:notice] = t('msg.saved_changes')
      redirect_to expert_url(@expert) and return
    else
      flash.now[:alert] = t('msg.could_not_save_changes')
    end

    @title = t('label.edit_expert')
    render :form
  end

  # Deletes the expert and redirects to the experts index page.
  def destroy
    expert = Expert.find(params[:id])

    if expert.destroy
      flash[:notice] = t('msg.deleted_expert', expert: expert.name)
  	  redirect_to experts_url
    else
      flash[:alert] = t('msg.could_not_delete_expert')
      redirect_to expert_url(expert)
    end
  end

  # Sets a not found flash and redirects to the experts index page.
  def not_found
    flash[:alert] = t('msg.expert_not_found')
    redirect_to experts_url
  end
end
