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
    @experts = Expert.with_documents.limit(50).page(params[:page]).order(:name)
    @title = t('labels.generic.search')
  end

  # Searches for experts.
  def search
    @experts = Expert.with_documents.search(params).limit(50).page(params[:page])
    @title = t('labels.generic.search')
    @body_class << :index
    render :index
  end

  # Serves the experts details page.
  def show
    @expert = Expert.find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Serves an addresses and contacts page.
  def contact
    @expert = Expert.find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Serves the experts documents page.
  def documents
    @expert = Expert.includes(cvs: :attachment).find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Sends a generated pdf including the experts deatils.
  def report
    e = Expert.find(params[:id])
    send_data ExpertsReport.for_expert(e).render,
              filename: "report-#{e.full_name.parameterize}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  # Servers a blank experts form
  def new
    @expert = Expert.new
    @title = t('labels.expert.new')
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
      flash[:notice] = t('messages.expert.success.create', name: @expert.name)
      redirect_to expert_url(@expert) and return
    else
      flash[:alert] = t('messages.expert.errors.create')
    end

    @title = t('labels.expert.new')
    @body_class << :new
    render :form
  end

  # Serves an edit form, populated with the experts data.
  def edit
    @expert = Expert.find(params[:id])
    @title = t('labels.expert.new')
    render :form
  end

  # Updates an expert and redirects to the experts details page on success.
  def update
    @expert = Expert.find(params[:id])
    @expert.user = current_user

    if (comment = params[:expert].try(:delete, :comment))
      @expert.comment.comment = comment[:comment]
    end

    @expert.attributes = params[:expert]
    @expert.languages = params[:languages]

    if @expert.save
      flash[:notice] = t('messages.expert.success.save')
      redirect_to expert_url(@expert) and return
    else
      flash.now[:alert] = t('messages.expert.errors.save')
    end

    @title = t('labels.expert.edit')
    @body_class << :edit
    render :form
  end

  # Deletes the expert and redirects to the experts index page.
  def destroy
    expert = Expert.find(params[:id])

    if expert.destroy
      flash[:notice] = t('messages.expert.success.delete', name: expert.name)
  	  redirect_to experts_url
    else
      flash[:alert] = t('messages.expert.errors.delete')
      redirect_to expert_url(expert)
    end
  end

  # Sets a not found flash and redirects to the experts index page.
  def not_found
    flash[:alert] = t('messages.expert.errors.find')
    redirect_to experts_url
  end
end
