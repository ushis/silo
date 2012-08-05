# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController
  before_filter :authorize, except: [:index]

  #
  def authorize
    unless current_user.access?(:experts)
      flash[:alert] = t('msg.access_denied')
      redirect_to experts_url
    end
  end

  # Serves a paginated table of all experts.
  def index
    @title = t('label.experts')
    @experts = Expert.limit(25)
  end

  #
  def destroy
    expert = Expert.find(params[:id])

    if expert.destroy
      flash[:notice] = t('msg.expert_deleted', expert: expert.name)
    else
      flash[:alert] = t('msg.could_not_delete_expert')
    end

  	redirect_to experts_url
  end

  #
  def not_found
    flash[:alert] = t('msg.expert_not_found')
    redirect_to experts_url
  end
end
