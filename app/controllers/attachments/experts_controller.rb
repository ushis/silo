# The Attachments::ExpertsController provides actions to add/remove
# attachments to/from an Expert model. The real stuff happens in the
# AttachmentsController.
class Attachments::ExpertsController < AttachmentsController

  # Checks, if the user has access to the _experts_ section.
  def authorize
    super(:experts, experts_url)
  end

  # Adds an uploaded attachment to an Expert.
  def create
    expert = Expert.find(params[:expert_id])
    add_to expert, documents_expert_url(expert)
  end

  # Destroys an Attachment and redirects the user to the experts documents
  # pages.
  def destroy
    super
    redirect_to documents_expert_url(id: params[:expert_id])
  end

  # Sets a not found flash message and redirects the user.
  def not_found
    super(experts_url)
  end
end
