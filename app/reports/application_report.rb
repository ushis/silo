require 'prawn'

class ApplicationReport < Prawn::Document
  include ActionView::Helpers::TranslationHelper

  def initialize(title)
    super({})
    font 'Helvetica', size: 11
    text title, size: 20, style: :bold
    move_down 16
  end
end
