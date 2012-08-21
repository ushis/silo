require 'bluecloth'
require 'silo_page_links'

# Contains several generic helper methods.
module ApplicationHelper

  # Returns all flash messages in separate div boxes.
  #
  #   flash_all
  #   #=> '<div class="flash alert">Something happend!</div>'
  def flash_all
    flash.inject('') do |html, item|
      html << content_tag(:div, item[1], class: "flash #{item[0].to_s}")
    end.html_safe
  end

  # Renders markdown formatted text.
  def markdown(txt)
    BlueCloth.new(txt, auto_links: true, escape_html: true).to_html.html_safe
  end

  # Returns the value of a param as JSON.
  #
  #   params_as_json(:languages, Array)
  #   #=> ["1", "7"]
  #
  # If the param is not an object of the specified klass, a new object is
  # initialized.
  def param_as_json(key, klass)
    (params[key].is_a?(klass) ? params[key] : klass.new).to_json.html_safe
  end

  # Checks if the current user has access to the section and adds a
  # 'disabled' class to the link if not.
  #
  #   resctricted_link_to 'secure stuff', url, :experts
  #   #=> '<a href="#" class="disabled">secure stuff</a>'
  def restricted_link_to(txt, path, section, opt = {})
    unless current_user.access?(section)
      opt[:class] = opt[:class].to_s << ' disabled'
    end

    link_to(txt, path, opt)
  end

  # Returns a pagination list.
  #
  #   paginate(@experts)
  #   #=> '<ul><li><span>1</span></li><li><a>2</a></li></ul>'
  def paginate(collection)
    if collection && collection.respond_to?(:total_pages)
      will_paginate(collection, { outer_window: 0, inner_window: 2,
                                  renderer: SiloPageLinks::Renderer } )
    end
  end

  # Returns a conditional comment tag.
  #
  #   condition_comment_tag(:IE) { content_tag :p, 'Hello IE' }
  #   #=> '<!--[if IE]><p>Hello IE</p><![endif]-->'
  def conditional_comment_tag(condition)
    "<!--[if #{condition}]>#{yield}<![endif]-->".html_safe
  end

  # Returns a conditional comment tag including a JavaScript redirect.
  def redirect_ie
    conditional_comment_tag :IE do
      content_tag :script, "window.location.replace('/ie.html');".html_safe
    end
  end
end
