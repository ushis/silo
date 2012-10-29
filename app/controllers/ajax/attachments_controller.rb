# The Ajax::AttachmentsController handles Attachment specific AJAX requests.
class Ajax::AttachmentsController < AjaxController
  respond_to :html, only: [:new]

  caches_action :new

  # Serves an empty attachment form.
  def new
    @attachment = Attachment.new
    @url = { controller: '/attachments', action: :create }
  end
end
