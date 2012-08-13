require 'prawn'

# The ApplicationReport is parent class of all reports. It intializes the
# prawn document and sets the global content and style.
class ApplicationReport < Prawn::Document
  include AbstractController::Translation

  # Initializes the Document and sets the title.
  def initialize(title)
    super({})
    font 'Helvetica', size: 11
    text title, size: 20, style: :bold
    move_down 16
  end
end
