require 'prawn'

# The ApplicationReport is parent class of all reports. It intializes the
# prawn document and sets the global content and style.
class ApplicationReport < Prawn::Document
  include AbstractController::Translation

  # Initializes the Document and sets the title.
  def initialize(title, user)
    super({})
    font 'Helvetica', size: 10
    stroke_color 'd0d0d0'

    bounding_box [0, (y - 30)], width: 520 do
      text "#{user.full_name}   -   #{l(Time.now, format: :long)}", size: 9
      stroke { line(bounds.bottom_left, bounds.bottom_right) }
    end

    move_down 22
    text title, size: 20, style: :bold
    move_down 10
  end
end
