require 'carmen'
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

  # Alias for Language.select_box_friendly
  def list_languages
    @list_languages ||= Language.select_box_friendly
  end

  # Returns a language select box.
  def language_select_tag(name, val = nil, opt = {})
    val = val.id if val.is_a? Language
    opts = options_for_select(list_languages, val)
    select_tag name, opts, opt
  end

  # Returns multiple language select boxes.
  def language_select_tags(langs)
    langs = [nil] if langs.empty?

    langs.collect do |lang|
      language_select_tag 'languages[]', lang
    end.join('').html_safe
  end

  # Returns all countries in a select box friendly format.
  def list_countries
    @countries ||= Rails.cache.fetch("countries_#{I18n.locale}") do
      Carmen::Country.all.sort { |x, y| x.name <=> y.name }.collect do |c|
        [c.name, c.code]
      end
    end
  end

  # Returns a country select box.
  def country_select_tag(name, val = nil, opt = {})
    select_tag name, options_for_select(list_countries, val), opt
  end

  # Returns select box options with all possible contact fields.
  def contact_field_options
    options_for_select Contact.select_box_friendly_fields
  end

  # Returns the contact value. If field is :emails or :websites, the value
  # is wrapped with <a> tag.
  def contact_value(val, field, html_options = {})
    case field
    when :emails
      mail_to val
    when :websites
      link_to val, (URI.parse(val).scheme.blank? ? "http://#{val}" : val)
    else
      val
    end
  end

  # Returns a delete contact button.
  #
  #   delete_contact_button('x', contact_url(contact), :emails, 'alf@aol.com')
  def delete_contact_button(txt, url, field, contact, html_options = {})
    form_tag url, method: :delete, class: 'button_to' do
      html = hidden_field_tag('contact[field]', field)
      html << hidden_field_tag('contact[contact]', contact)
      html << submit_tag(txt, html_options)
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
