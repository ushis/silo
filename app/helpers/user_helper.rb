# Provides user specific helpers.
module UserHelper

  # Returns a string, containing all the users privileges in _spans_.
  # The CSS _checked_ class is applied, if the user has access to the
  # corresponding section.
  #
  #   list_privileges(user)
  #   #=> '<span>experts</span><span class="checked">partners</span>'
  def list_privileges(user, klass)
    user.privileges.inject('') do |html, item|
      html << content_tag(:span, class: (item[1] ? klass : nil)) do
        Privilege.human_attribute_name(item[0])
      end
    end.html_safe
  end

  # Returns all available locales in a select box friendly format.
  #
  #   list_locales
  #   #=> [['English', :en], ['German', :de]]
  def list_locales
    User::LOCALES.collect { |l| [t(l, scope: :language), l] }
  end

  # Returns the user's fullname and its username in brackets.
  def full_user_link(user)
    link_to edit_user_path(user) do
      html = content_tag :strong, "#{user.prename} #{user.name}"
      html << " (#{user.username})"
    end
  end
end
