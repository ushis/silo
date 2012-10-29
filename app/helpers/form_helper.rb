# Defines our custom form builder and some form specific helpers.
module FormHelper

  # Returns a contact field select box with localized options.
  def contact_field_select_tag(name, options = {})
    select_tag(name,
               options_for_select(contact_field_list, options.delete(:value)),
               options)
  end

  private

  # Returns a select box friendly list of all contact fields
  def contact_field_list
    @contact_field_list ||= Contact::FIELDS.collect do |f|
      [I18n.t(f.to_s.singularize, scope: [:values, :contacts]), f]
    end
  end

  public

  # Silos custom FormBuilder defines several helpers such as
  # FormBuilder#country_select and FormBuilder#language_select.
  class FormBuilder < ActionView::Helpers::FormBuilder

    # Returns a grouped collection select box containing all countries grouped
    # by area and ordered by their localized names.
    def country_select(method, options = {}, html_options = {})
      grouped_collection_select(method, all_areas, :countries, :human,
                                :id, :human, options, html_options)
    end

    # Returns a collection select box containing all languages.
    def language_select(method, options = {}, html_options = {})
      collection_select(method, all_languages, :id, :human,
                        options, html_options)
    end

    # Returns fields for privileges. Its a bunch of check boxes and labels.
    def privilege_fields(method, disabled = false)
      fields_for @object.send(method) do |fields|
        html = fields.check_box(:admin, disabled: disabled, class: :admin)
        html << fields.label(:admin, class: :admin)

        Privilege::SECTIONS.reverse_each do |section|
          html << fields.check_box(section, disabled: disabled)
          html << fields.label(section)
        end

        html
      end
    end

    private

    # Returns all areas with their ordered countries.
    def all_areas
      @all_areas ||= Area.with_ordered_countries
    end

    # Returns all languages ordered by priority.
    def all_languages
      @all_languages ||= Language.priority_ordered
    end
  end
end
