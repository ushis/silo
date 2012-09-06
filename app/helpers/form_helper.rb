# Defines our custom form builder and some form specific helpers.
module FormHelper

  # Silos custom FormBuilder defines several helpers such as
  # FormBuilder#country_select and FormBuilder#language_select.
  class FormBuilder < ActionView::Helpers::FormBuilder
    require_dependency 'area'
    require_dependency 'country'
    require_dependency 'language'

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

    private

    # Returns all areas with their ordered countries.
    def all_areas
      @all_areas ||= Rails.cache.fetch("#{I18n.locale}/all_areas") do
        Area.with_ordered_countries
      end
    end

    # Returns all languages ordered by priority.
    def all_languages
      @all_languages ||= Rails.cache.fetch("#{I18n.locale}/all_languages") do
        Language.priority_ordered
      end
    end
  end
end
