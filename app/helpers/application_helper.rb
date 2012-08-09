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

  #
  def languages
    @language_collection ||= Language.all
  end

  #
  def language_select(lang)
    fields_for lang do |f|
      f.collection_select :id, languages, :id, :human, {}, name: 'languages[]'
    end.html_safe
  end

  #
  def language_selects(langs)
    if langs.empty?
      language_select Language.first
    else
      langs.collect { |lang| language_select lang }.join('').html_safe
    end
  end

  #
  def list_contact_fields
    Contact::FIELDS.collect do |f|
      content_tag :option, t(f.to_s.singularize, scope: :label), value: f
    end.join('').html_safe
  end

  def delete_contact_button(txt, url, field, contact)
    form_tag url, method: :delete, class: 'button_to' do
      [ hidden_field_tag('contact[field]', field),
        hidden_field_tag('contact[contact]', contact),
        submit_tag(txt, class: 'delete') ].join('').html_safe
    end
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
