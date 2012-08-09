#
class Contacts::ExpertsController < ContactsController

  def authorize
    unless current_user.access?(:experts)
      flash[:alert] = t('msg.access_denied')
      redirect_to experts_url
    end
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
