# Handles all partner related requests.
class PartnersController < ApplicationController
  before_filter :check_password, only: [:destroy]

  skip_before_filter :authorize, only: [:index, :show, :documents]

  cache_sweeper :tag_sweeper, only: [:create, :update]

  # Checks the users permissions.
  def authorize
    super(:partners, partners_url)
  end

  # Searches for partners.
  def index
    _params = params.merge(arrayified_params(:businesses, :countries))
    @partners = Partner.with_meta.search(_params).page(params[:page])
    @title = t('labels.partner.all')
  end

  # Serves the partners details page.
  def show
    @partner = Partner.find(params[:id])
    @title = @partner.company

    respond_to do |format|
      format.html
      format.pdf { send_report PartnerReport.new(@partner, current_user) }
    end
  end

  # Serves the experts documents page.
  def documents
    @partner = Partner.find(params[:id])
    @title = @partner.company
  end

  # Serves an empty partner form.
  def new
    @partner = Partner.new
    @title = t('labels.partner.new')
    render :form
  end

  # Creates a new partner.
  def create
    @partner = Partner.new(params[:partner])
    @partner.user = current_user

    if @partner.save
      flash[:notice] = t('messages.partner.success.create', name: @partner.company)
      redirect_to partner_url(@partner) and return
    end

    flash.now[:alert] = t('messages.partner.errors.create')
    @title = t('labels.partner.new')
    body_class << :new
    render :form
  end

  # Serves an edit form.
  def edit
    @partner = Partner.find(params[:id])
    @title = t('labels.partner.edit')
    render :form
  end

  # Updates the partner.
  def update
    @partner = Partner.find(params[:id])
    @partner.user = current_user
    @partner.attributes = params[:partner]

    if @partner.save
      flash[:notice] = t('messages.partner.success.save')
      redirect_to partner_url(@partner) and return
    end

    flash.now[:alert] = t('messages.partner.errors.save')
    @title = t('labels.partner.edit')
    body_class << :edit
    render :form
  end

  # Deletes the partner.
  def destroy
    partner = Partner.find(params[:id])

    if partner.destroy
      flash[:notice] = t('messages.partner.success.delete', name: partner.company)
      redirect_to partners_url
    else
      flash[:alert] = t('messages.partner.errors.delete')
      redirect_to partner_url(partner)
    end
  end

  private

  # Sets an error message and redirects the user.
  def not_found
    flash[:alert] = t('messages.partner.errors.find')
    redirect_to partners_url
  end
end
