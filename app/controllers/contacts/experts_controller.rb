#
class Contacts::ExpertsController < ContactsController

  def authorize
    super(:experts, experts_url)
  end

  def create
    expert = Expert.includes(:contact).find(params[:expert_id])
    add_to expert, contact_expert_url(expert)
  end

  def destroy
    expert = Expert.includes(:contact).find(params[:expert_id])
    remove_from expert, contact_expert_url(expert)
  end

  def not_found
    flash[:alert] = t('msg.expert_not_found')
    redirect_to experts_url
  end
end
