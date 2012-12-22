require 'prawn'

# The ApplicationReport is parent class of all reports. It intializes the
# prawn document and sets the global content and style.
class ApplicationReport < Prawn::Document
  include AbstractController::Translation

  attr_reader :title

  # Initializes the Document and sets the title.
  def initialize(record, user, options = {})
    options[:page_size] = [595.28, 841.86]

    if options.delete(:layout) == :landscape
      options[:page_size].reverse!
    end

    super(options)
    @width = options[:page_size].first
    @height = options[:page_size].last
    @record = record
    @model = record.class
    @title = record.to_s

    head(user.full_name)
    h1 @title
  end

  # Builds the page head.
  def head(name)
    font 'Helvetica', size: 9
    stroke_color 'd0d0d0'

    bounding_box [0, (y - 30)], width: (@width - 72) do
      text "#{name}   -   #{l(Time.now, format: :long)}", size: 9
      stroke { line(bounds.bottom_left, bounds.bottom_right) }
    end

    gap 22
  end

  # Adds a first level headline.
  def h1(content)
    text content, size: 20, style: :bold
    gap 10
  end

  # Adds a second level headline to the report.
  def h2(content, is_attr = true)
    content = @model.human_attribute_name(content) if is_attr
    text content, size: 12, style: :bold
    gap 10
  end

  # Adds a first level headline.
  def h3(content)
    text content, size: 10, style: :bold
    gap 10
  end

  # Adds an indeted text.
  def p(content)
    indent(5) { text content }
  end

  # Moves the cursor down.
  def gap(len = 16)
    move_down len
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
      table.width = @width - 72
      table.row_colors = ['f6f6f6', 'ffffff']
      yield(table) if block_given?
    end
  end

  # Builds a info table for a record.
  def info_table(record = @record)
    model = record.class

    data = model.exposable_attributes(human: true).map do |attribute, method|
      [model.human_attribute_name(attribute), record.send(method).to_s]
    end

    table data
    gap
  end

  # Builds a contact table.
  def contacts_table(record = @record)
    data = Contact::FIELDS.map do |field|
      values = record.contact.send(field)
      [t(field, scope: [:values, :contacts]), values.join(', ')]
    end

    table data
    gap
  end

  # Builds a comment.
  def comment
    h2 :comment
    p @record.comment.blank?  ? '-' : @record.comment.to_s
    gap
  end
end
