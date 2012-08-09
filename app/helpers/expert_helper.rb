# Provides expert specific helpers.
module ExpertHelper

  # Returns all available genders in a select box freindly format.
  #
  #   list_genders
  #   #=> [['Female', :female], ['Male', :male]]
  def list_genders
    Expert::GENDERS.collect { |g| [t(g, scope: :gender), g] }
  end

  # Returns all available degrees in a select box friendly format.
  def list_degrees
    Expert::DEGREES.collect do |d|
      [t(d, scope: :degree), d]
    end.unshift([t(:none, scope: :label), nil])
  end

  # Returns a string containing links to the CV downloads.
  #
  #   list_cvs(expert)
  #   #=> '<a href="">en</a><a href="">de</a>'
  def list_cvs(expert)
    expert.cvs.inject('') do |ret, cv|
      ret << link_to(cv.language.language, [expert, cv])
    end.html_safe
  end
end
