require 'silo_page_links'

# Contains several generic helper methods.
module ApplicationHelper

  # Returns all flash messages in separate div boxes.
  #
  #   flash_all
  #   #=> '<div class="flash alert">Something happend!</div>'
  def flash_all
    flash.inject('') do |ret, item|
      ret << content_tag(:div, item[1], class: "flash #{item[0].to_s}")
    end.html_safe
  end

  # Returns a pagination list.
  #
  #   paginate(@experts)
  #   #=> '<ul><li><span>1</span></li><li><a>2</a></li></ul>'
  def paginate(collection)
    if collection
      will_paginate collection, inner_window: 3, renderer: SiloPageLinks::Renderer
    end
  end
end
