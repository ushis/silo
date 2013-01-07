# The Ajax::CvsController handles Cv specific AJAX requests.
class Ajax::CvsController < Ajax::ApplicationController
  respond_to :html, only: [:new]

  caches_action :new

  # Serves an empty cvs form.
  def new
    @cv = Cv.new
    @url = { controller: '/cvs', action: :create }
  end
end
