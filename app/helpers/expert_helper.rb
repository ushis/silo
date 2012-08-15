# Provides expert specific helpers.
module ExpertHelper

  # Returns a gender select box
  def gender_select_tag(name, val = nil, opt = {})
    select_tag name, options_for_select(list_genders, val), opt
  end

  # Returns all available genders in a select box freindly format.
  #
  #   list_genders
  #   #=> [['Female', :female], ['Male', :male]]
  def list_genders
    Expert::GENDERS.collect { |g| [t(g, scope: :gender), g] }
  end

  # Returns a string containing links to the CV downloads.
  #
  #   list_cvs(expert)
  #   #=> '<a href="">en</a><a href="">de</a>'
  def list_cvs(expert)
    expert.cvs.inject('') do |html, cv|
      html << link_to(cv.language.language, [expert, cv])
    end.html_safe
  end
end
