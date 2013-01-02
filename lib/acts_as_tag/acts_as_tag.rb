module ActsAsTag
  module ActsAsTag
    extend ActiveSupport::Concern

    # Defines the magic methods ClassMethods#acts_as_tag
    #
    # See ActsAsTag for more info.
    module ClassMethods

      # Makes a model acting as a tag.
      def acts_as_tag(attribute_name)
        class_attribute :tag_attribute

        self.tag_attribute = attribute_name

        attr_accessible(attribute_name)

        default_scope(order(attribute_name))

        validates(attribute_name, presence: true, uniqueness: true)

        extend ClassMethodsOnActivation
        include InstanceMethodsOnActivation
      end
    end

    # Mixes class methods into the model.
    module ClassMethodsOnActivation

      # Labels the model as a tag.
      def acts_as_tag?
        true
      end

      # Extracts tags from a string.
      #
      # Returns a collection of tag like objects.
      def from_s(s, delimiter = ',')
        tags = s.split(delimiter).inject({}) do |hsh, tag|
          tag.strip!
          hsh[tag.downcase] ||= tag unless tag.empty?
          hsh
        end

        tags.empty? ? [] : multi_find_or_initialize(tags.values)
      end

      # Finds or initialized multiple tags by tag attribute.
      #
      # Returns a collection of old and fresh tag like objects.
      def multi_find_or_initialize(tags)
        old_tags = where("LOWER(#{tag_attribute}) IN (?)", tags.map(&:downcase))

        old_tags.each do |old_tag|
          tags.delete_if { |tag| tag.casecmp(old_tag.to_s) == 0 }
        end

        old_tags + tags.map { |tag| new(tag_attribute => tag) }
      end
    end

    # Mixes instance methods into the  model.
    module InstanceMethodsOnActivation

      # Returns the tag attribute.
      def to_s
        send(tag_attribute).to_s
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsTag::ActsAsTag
