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
end
