#
class Addresses::ExpertsController < AddressesController

  def authorize
    unless current_user.admin?
      flash[:alert] = t('msg.access_denied')
      redirect_to experts_url
    end
  end

  def create
    expert = Expert.includes(:addresses).find(params[:expert_id])
    append_to expert, contact_expert_url(expert)
  end

  def destroy
    super
    redirect_to contact_expert_url(id: params[:expert_id])
  end

  def not_found
    flash[:alert] = t('msg.expert_not_found')
    redirect_to experts_url
  end
end
