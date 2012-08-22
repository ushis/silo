# Contains language specific helper methods.
module LanguageHelper

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
end
