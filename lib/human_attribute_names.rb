# Mixes the method HumanAttributeNames#human_attribute_names
# into ActiveRecord.
module HumanAttributeNames
  extend ActiveSupport::Concern

  module ClassMethods

    # Returns a string containing comma separated localized attribute names.
    #
    #  User.human_attribute_names(:name, :firstname, :degree)
    #  #=> "Name, Vorname und Abschluss"
    def human_attribute_names(*attributes)
      attributes.collect do |attr|
        human_attribute_name(attr)
      end.to_sentence
    end
  end
end

ActiveRecord::Base.send :include, HumanAttributeNames
