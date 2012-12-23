# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController
  before_filter :check_password, only: [:destroy]

  skip_before_filter :authorize, only: [:index, :show, :documents]

  # Checks if the user has access to the experts section.
  def authorize
    super(:experts, experts_url)
  end

  # Serves a paginated table of all experts.
  def index
    _params = params.merge(arrayified_params(:country, :languages))
    @experts = Expert.with_meta.search(_params).page(params[:page])
    @title = t('labels.expert.all')
  end

  # Serves the experts details page.
  def show
    @expert = Expert.find(params[:id])
    @title = @expert.full_name_with_degree

    respond_to do |format|
      format.html
      format.pdf { send_report ExpertReport.new(@expert, current_user) }
    end
  end

  # Serves the experts documents page.
  def documents
    @expert = Expert.find(params[:id])
    @title = @expert.full_name_with_degree
  end

  # Servers a blank experts form
  def new
    @expert = Expert.new
    @title = t('labels.expert.new')
    render :form
  end

  # Creates a new expert and redirects to the experts details page on success.
  def create
    @expert = Expert.new(params[:expert])
    @expert.user = current_user

    if @expert.save
      flash[:notice] = t('messages.expert.success.create', name: @expert.name)
      redirect_to expert_url(@expert) and return
    end

    flash.now[:alert] = t('messages.expert.errors.create')
    @title = t('labels.expert.new')
    body_class << :new
    render :form
  end

  # Serves an edit form, populated with the experts data.
  def edit
    @expert = Expert.find(params[:id])
    @title = t('labels.expert.edit')
    render :form
  end

  # Updates an expert and redirects to the experts details page on success.
  def update
    @expert = Expert.find(params[:id])
    @expert.user = current_user

    if @expert.update_attributes(params[:expert])
      flash[:notice] = t('messages.expert.success.save')
      redirect_to expert_url(@expert) and return
    end

    flash.now[:alert] = t('messages.expert.errors.save')
    @title = t('labels.expert.edit')
    body_class << :edit
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

  private

  # Sets a not found flash and redirects to the experts index page.
  def not_found
    flash[:alert] = t('messages.expert.errors.find')
    redirect_to experts_url
  end
end
