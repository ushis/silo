# The Ajax::TagsController provides helpers to access existing tag like models.
# They should be used to help the user by filling out forms with widgets such
# as autocompletion or multiselect boxes.
class Ajax::TagsController < Ajax::ApplicationController
  before_filter :find_model

  caches_action :show

  # Serves tags in a multiselect box or as JSON.
  #
  # GET /ajax/tags/model_name
  def show
    @tags = @model.all
    @title = t(:"labels.#{@model.name.downcase}.index")
    respond_with(@tags)
  end

  private

  # Finds the model.
  def find_model
    begin
      @model = params[:id].to_s.classify.constantize
    rescue NameError
      not_found and return
    end

    unless @model.respond_to?(:acts_as_tag?) && @model.acts_as_tag?
      not_found
    end
  end

  # Sends a 404 with a proper error message.
  def not_found
    super('Tags not found.')
  end
end
