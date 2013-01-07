# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController
  before_filter :check_password, only: [:destroy]
  before_filter :find_expert,    only: [:show, :documents, :edit, :update, :destroy]

  skip_before_filter :authorize, only: [:index, :show, :documents]

  # Serves a paginated table of all experts.
  #
  # GET /experts
  def index
    _params = params.merge(arrayified_params(:country, :languages))
    @experts = Expert.with_meta.search(_params).page(params[:page])
    @title = t('labels.expert.all')
  end

  # Serves the experts details page.
  #
  # GET /experts/:id
  def show
    @title = @expert.full_name_with_degree

    respond_to do |format|
      format.html
      format.pdf { send_report ExpertReport.new(@expert, current_user) }
    end
  end

  # Serves the experts documents page.
  #
  # GET /experts/:id/documents
  def documents
    @title = @expert.full_name_with_degree
  end

  # Servers a blank experts form
  #
  # GET /experts/new
  def new
    @expert = Expert.new
    render_form(:new)
  end

  # Creates a new expert and redirects to the experts details page on success.
  #
  # POST /experts
  def create
    @expert = current_user.experts.build(params[:expert])

    if @expert.save
      flash[:notice] = t('messages.expert.success.create', name: @expert.name)
      redirect_to expert_url(@expert)
    else
      flash.now[:alert] = t('messages.expert.errors.create')
      render_form(:new)
    end
  end

  # Serves an edit form, populated with the experts data.
  #
  # GET /experts/:id/edit
  def edit
    render_form(:edit)
  end

  # Updates an expert and redirects to the experts details page on success.
  #
  # PUT /experts/:id
  def update
    @expert.user = current_user

    if @expert.update_attributes(params[:expert])
      flash[:notice] = t('messages.expert.success.save')
      redirect_to expert_url(@expert)
    else
      flash.now[:alert] = t('messages.expert.errors.save')
      render_form(:edit)
    end
  end

  # Deletes the expert and redirects to the experts index page.
  #
  # DELETE /experts/:id
  def destroy
    if @expert.destroy
      flash[:notice] = t('messages.expert.success.delete', name: @expert.name)
      redirect_to experts_url
    else
      flash[:alert] = t('messages.expert.errors.delete')
      redirect_to expert_url(@expert)
    end
  end

  private

  # Checks if the user has access to the experts section.
  def authorize
    super(:experts, experts_url)
  end

  # Finds the expert.
  def find_expert
    @expert = Expert.find(params[:id])
  end

  # Renders the experts form
  def render_form(action)
    body_class << action
    @title = t("labels.expert.#{action}")
    render :form
  end

  # Sets a not found flash and redirects to the experts index page.
  def not_found
    flash[:alert] = t('messages.expert.errors.find')
    redirect_to experts_url
  end
end
