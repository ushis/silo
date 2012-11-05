# The Ajax::TagsController provides helpers to access existing tag like models.
# They should be used to help the user by filling out forms with widgets such
# as autocompletion or multiselect boxes.
class Ajax::TagsController < AjaxController
  rescue_from NotATagError, with: :not_found

  caches_action :show

  # Serves tags in a multiselect box or as JSON.
  #
  # GET /ajax/tags/model_name
  def show
    @tags = model.all
    @title = t(:"labels.#{model.name.downcase}.index")
    respond_with(@tags)
  end

  private

  # Finds the model and checks if it acts as a tag.
  # Raises NotATagError on error.
  def model
    model = params[:id].to_s.classify.constantize

    unless model.respond_to?(:acts_as_tag?) && model.acts_as_tag?
      raise NotATagError, model.name
    end

    model
  rescue NameError => e
    raise NotATagError, e.name
  end

  # Sends a 404 with a proper error message.
  def not_found
    super('Tags not found.')
  end
end
