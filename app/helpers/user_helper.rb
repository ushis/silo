# Provides user specific helpers.
module UserHelper

  # Returns a string, containing all the users privileges in _spans_.
  # The CSS _checked_ class is applied, if the user has access to the
  # corresponding section.
  #
  #   list_privileges(user)
  #   #=> '<span>experts</span><span class="checked">partners</span>'
  def list_privileges(user)
    user.privileges.inject('') do |ret, item|
      klass = 'checked' if item[1]
      ret << content_tag(:span, t(item[0], scope: :label), class: klass)
    end.html_safe
  end

  # Returns all available locales in a select box friendly format.
  #
  #   list_locales
  #   #=> [['English', :en], ['German', :de]]
  def list_locales
    User::LOCALES.collect { |l| [t(l, scope: :label), l] }
  end
end
