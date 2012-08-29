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

  # Adds a second level headline to the report.
  def h2(content)
    text content, size: 12, style: :bold
    move_down 10
  end

  # Sets some default table options.
  def table(data, options = {})
    settings = {
      cell_style: {
        borders: [],
        padding: 5
      }
    }.merge(options)

    super(data, settings) do |table|
      table.width = 520
      table.row_colors = ['f6f6f6', 'ffffff']
      yield(table) if block_given?
    end
  end
end
