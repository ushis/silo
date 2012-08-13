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

  # Returns a collection of all languages
  def languages
    @languages ||= Rails.cache.fetch("languages_#{I18n.locale}") do
      Language.all.sort { |x, y| x.human <=> y.human }
    end
  end

  # Returns a single language select boxes.
  def language_select(lang = Language.new, opt = {})
    fields_for lang do |f|
      f.collection_select :id, languages, :id, :human, opt, name: 'languages[]'
    end.html_safe
  end

  # Returns multiple language select boxes.
  def language_selects(langs)
    if langs.empty?
      language_select
    else
      langs.collect { |lang| language_select lang }.join('').html_safe
    end
  end

  # Returns select box options with all possible contact fields.
  def list_contact_fields
    Contact::FIELDS.collect do |f|
      content_tag :option, t(f.to_s.singularize, scope: :label), value: f
    end.join('').html_safe
  end

  # Returns a delete contact button.
  #
  #   delete_contact_button('x', contact_url(contact), :emails, 'alf@aol.com')
  def delete_contact_button(txt, url, field, contact)
    form_tag url, method: :delete, class: 'button_to' do
      html = hidden_field_tag('contact[field]', field)
      html << hidden_field_tag('contact[contact]', contact)
      html << submit_tag(txt, class: 'delete')
      html.html_safe
    end
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
end
