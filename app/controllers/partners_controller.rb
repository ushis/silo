#
class PartnersController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show]

  cache_sweeper :business_sweeper, only: [:create, :update]

  #
  def authorize
    super(:partners, partners_url)
  end

  #
  def index
    _params = params.merge(arrayified_params(:businesses, :countries))
    @partners = Partner.with_meta.search(_params).limit(50).page(params[:page])
    @title = t('labels.partner.all')
  end

  # Serves the partners details page.
  def show
    @partner = Partner.find(params[:id])
    @title = @partner.company
  end

  # Serves the experts documents page.
  def documents
    @partner = Partner.find(params[:id])
    @title = @partner.company
  end

  #
  def new
    @partner = Partner.new
    @title = t('labels.partner.new')
    render :form
  end

  #
  def create
    @partner = Partner.new(params[:partner])
    @partner.user = current_user
    @partner.contact_persons = arrayified_param(:contact_persons)

    if @partner.save
      flash[:notice] = t('messages.partner.success.create', name: @partner.company)
      redirect_to partner_url(@partner) and return
    end

    flash.now[:alert] = t('messages.partner.errors.create')
    @title = t('labels.partner.new')
    body_class << :new
    render :form
  end

  #
  def edit
    @partner = Partner.find(params[:id])
    @title = t('labels.partner.edit')
    render :form
  end

  #
  def update
    @partner = Partner.find(params[:id])
    @partner.user = current_user
    @partner.contact_persons = arrayified_param(:contact_persons)
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

  #
  def destroy
    partner = Partner.find(params[:id])

    unless current_user.authenticate(params[:password])
      flash[:alert] = t('messages.user.errors.password')
      redirect_to partner_url(partner) and return
    end

    if partner.destroy
      flash[:notice] = t('messages.partner.success.delete', name: partner.company)
      redirect_to partners_url
    else
      flash[:alert] = t('messages.partner.errors.delete')
      redirect_to partner_url(partner)
    end
  end

  #
  def not_found
    flash[:alert] = t('messages.partner.errors.find')
    refirect_to partners_url
  end
end
