# Handles all partner related requests.
class PartnersController < ApplicationController
  before_filter :check_password, only: [:destroy]
  before_filter :find_partner,   only: [:show, :documents, :edit, :update, :destroy]

  skip_before_filter :authorize, only: [:index, :show, :documents]

  cache_sweeper :tag_sweeper, only: [:create, :update]

  # Searches for partners.
  #
  # GET /partners
  def index
    _params = params.merge(arrayified_params(:businesses, :country))
    @partners = Partner.with_meta.search(_params).page(params[:page])
    @title = t('labels.partner.all')
  end

  # Serves the partners details page.
  #
  # GET /partners/:id
  def show
    @title = @partner.company

    respond_to do |format|
      format.html
      format.pdf { send_report PartnerReport.new(@partner, current_user) }
    end
  end

  # Serves the experts documents page.
  #
  # GET /partners/:id/documents
  def documents
    @title = @partner.company
  end

  # Serves an empty partner form.
  #
  # GET /partners/new
  def new
    @partner = Partner.new
    render_form(:new)
  end

  # Creates a new partner.
  #
  # POST /partners
  def create
    @partner = current_user.partners.build(params[:partner])

    if @partner.save
      flash[:notice] = t('messages.partner.success.create', name: @partner.company)
      redirect_to partner_url(@partner)
    else
      flash.now[:alert] = t('messages.partner.errors.create')
      render_form(:new)
    end
  end

  # Serves an edit form.
  #
  # GET /partners/:id/edit
  def edit
    render_form(:edit)
  end

  # Updates the partner.
  #
  # PUT /partners/:id
  def update
    @partner.user = current_user

    if @partner.update_attributes(params[:partner])
      flash[:notice] = t('messages.partner.success.save')
      redirect_to partner_url(@partner)
    else
      flash.now[:alert] = t('messages.partner.errors.save')
      render_form(:edit)
    end
  end

  # Deletes the partner.
  #
  # DELETE /partners/:id
  def destroy
    if @partner.destroy
      flash[:notice] = t('messages.partner.success.delete', name: @partner.company)
      redirect_to partners_url
    else
      flash[:alert] = t('messages.partner.errors.delete')
      redirect_to partner_url(@partner)
    end
  end

  private

  # Checks the users permissions.
  def authorize
    super(:partners, partners_url)
  end

  # Finds the partner.
  def find_partner
    @partner = Partner.find(params[:id])
  end

  # Renders the partners form.
  def render_form(action)
    body_class << action
    @title = t("labels.partner.#{action}")
    render :form
  end

  # Sets an error message and redirects the user.
  def not_found
    flash[:alert] = t('messages.partner.errors.find')
    redirect_to partners_url
  end
end
