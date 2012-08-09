class Attachments::ExpertsController < AttachmentsController

  def authorize
    unless current_user.access?(:experts)
      flash[:alert] = t('msg.access_denied')
      redirect_to experts_url
    end
  end

  def create
    expert = Expert.find(params[:expert_id])
    add_to expert, documents_expert_url(expert)
  rescue
    flash[:alert] = t('msg.expert_not_found')
    redirect_to experts_url
  end

  def destroy
    super
    redirect_to documents_expert_url(id: params[:expert_id])
  end

  def not_found
    super documents_expert_url(id: params[:expert_id])
  end
end