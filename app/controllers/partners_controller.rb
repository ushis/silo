#
class PartnersController < ApplicationController
  skip_before_filter :authorize, only: [:index, :search, :show]

  #
  def authorize
    super(:partners, partners_url)
  end

  #
  def index
    @partners = Partner.limit(50).page(params[:page]).order(:company)
    @title = t('labels.partner.all')
  end

  #
  def search
  end

  #
  def show
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
  end

  #
  def destroy
  end

  #
  def not_found
    flash[:alert] = t('messages.partner.errors.find')
    refirect_to partners_url
  end
end
