require 'bluecloth'
require 'silo_page_links'

# Contains several generic helper methods.
module ApplicationHelper
  ActionView::Base.default_form_builder = FormHelper::FormBuilder

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
  def markdown(txt = nil, &block)
    txt = capture(&block).strip_heredoc if block_given?

    content_tag :div, class: 'markdown' do
      BlueCloth.new(txt, auto_links: true, escape_html: true).to_html.html_safe
    end
  end

  # Returns an empty <div> with a proper icon-* class.
  #
  #   icon(:lock)  #=> '<div class="icon-lock"></div>'
  def icon(icon_name)
    content_tag :div, nil, class: "icon-#{icon_name}"
  end

  # Creates a delete button for a record.
  def delete_button_for(record, options = {})
    options = {
      url: record,
      method: :delete,
      password: true,
      class: 'icon-trash',
      confirm: t(:"messages.#{record.class.name.underscore.downcase}.confirm.delete")
    }.merge(options)

    options['data-password'] = options.delete(:password)
    link_to(t('actions.delete'), options.delete(:url), options)
  end

  # Creates an editable button for a records attribute.
  def editable_button_for(record, method, options = {})
    klass = record.class

    options = {
      url: [:ajax, record],
      'data-editable' => method,
      'data-prefix' => klass.name.underscore,
      'data-name' => klass.human_attribute_name(method),
      'data-editable-type' => klass.columns_hash[method.to_s].type,
      class: 'editable'
    }.merge(options)

    link_to(record.send(method) || '', options.delete(:url), options)
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
      will_paginate collection, outer_window: 0, inner_window: 2,
                                renderer: SiloPageLinks::Renderer
    end
  end
end
