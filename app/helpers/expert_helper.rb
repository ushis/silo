# Provides expert specific helpers.
module ExpertHelper

  # Defines list methods for each constant listed in Expert::CONSTANTS, such
  # as _gender_ and _marital_status_. Each method returns all available values
  # in a select box friendly format.
  #
  #   list_genders
  #   #=> [['Female', :female], ['Male', :male]]
  Expert::CONSTANTS.each do |method, values|
    define_method("list_#{method.to_s.pluralize}") do
      values.collect { |val| [t("label.#{val}"), val] }
    end
  end
end
