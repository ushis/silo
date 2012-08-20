# Mixes the method HumanAttributeNames#human_attribute_names
# into ActiveModel::Translation.
module HumanAttributeNames

  # Returns a string containing comma separated localized attribute names.
  #
  #  User.human_attribute_names(:name, :firstname)
  #  #=> "Name, Vorname"
  def human_attribute_names(*attributes)
    attributes.collect do |attr|
      human_attribute_name(attr)
    end.join(', ')
  end
end

ActiveModel::Translation.send :include, HumanAttributeNames
