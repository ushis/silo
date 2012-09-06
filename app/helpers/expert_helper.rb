# Provides expert specific helpers.
module ExpertHelper

  # Returns a string containing links to the CV downloads.
  #
  #   list_cvs(expert)
  #   #=> '<a href="">en</a><a href="">de</a>'
  def list_cvs(expert, html_options = {})
    expert.cvs.inject('') do |html, cv|
      html << link_to(cv.language.language, [expert, cv], html_options)
    end.html_safe
  end
end
