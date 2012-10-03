# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController
  skip_before_filter :authorize, only: [:index, :search, :show, :documents]

  # Checks if the user has access to the experts section.
  def authorize
    super(:experts, experts_url)
  end

  # Serves a paginated table of all experts.
  def index
    @experts = Expert.with_documents.limit(50).page(params[:page]).order(:name)
    @title = t('labels.expert.all')

    respond_to do |format|
      format.html
      format.pdf { search_report(@experts) }
    end
  end

  # Searches for experts.
  def search
    _params = params.merge(arrayified_params(:countries, :languages))
    @experts = Expert.with_documents.search(_params).limit(50).page(params[:page])
    @title = t('labels.expert.search')
    body_class << :index

    respond_to do |format|
      format.html { render :index }
      format.pdf  { search_report(@experts, _params) }
    end
  end

  # Serves the experts details page.
  def show
    @expert = Expert.find(params[:id])
    @title = @expert.full_name_with_degree

    respond_to do |format|
      format.html
      format.pdf { report(@expert) }
    end
  end

  # Serves the experts documents page.
  def documents
    @expert = Expert.includes(cvs: :attachment).find(params[:id])
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
    comment = params[:expert].try(:delete, :comment)

    @expert = Expert.new(params[:expert])
    @expert.user = current_user
    @expert.comment.comment = comment[:comment] if comment
    @expert.languages = arrayified_param(:languages)

    if @expert.save
      flash[:notice] = t('messages.expert.success.create', name: @expert.name)
      redirect_to expert_url(@expert) and return
    else
      flash[:alert] = t('messages.expert.errors.create')
    end

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

    if (comment = params[:expert].try(:delete, :comment))
      @expert.comment.comment = comment[:comment]
    end

    @expert.attributes = params[:expert]
    @expert.languages = arrayified_param(:languages)

    if @expert.save
      flash[:notice] = t('messages.expert.success.save')
      redirect_to expert_url(@expert) and return
    else
      flash.now[:alert] = t('messages.expert.errors.save')
    end

    @title = t('labels.expert.edit')
    body_class << :edit
    render :form
  end

  # Deletes the expert and redirects to the experts index page.
  def destroy
    expert = Expert.find(params[:id])

    unless current_user.authenticate(params[:password])
      flash[:alert] = t('messages.user.errors.password')
      redirect_to expert_url(expert) and return
    end

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

  private

  # Sends a generated pdf including the experts deatils.
  def report(expert)
    send_data ExpertsReport.for(expert, current_user).render,
              filename: "report-#{expert.full_name.parameterize}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  # Sends a pdf report of the search.
  def search_report(results, search_params)
    send_data ExpertsReport.for(results, current_user, search_params).render,
              filename: "report-#{l(Time.now, format: :save)}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end
end
