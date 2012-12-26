module ActsAsComment
  module ActsAsComment
    extend ActiveSupport::Concern

    # Defines ClassMethods#acts_as_comment.
    #
    # See ActsAsComment for more info.
    module ClassMethods

      # Makes a model acting as a comment.
      def acts_as_comment(attribute_name, options = {})
        class_attribute :comment_attribute

        self.comment_attribute = attribute_name

        attr_accessible(attribute_name)

        after_initialize do
          read_attribute(attribute_name) || write_attribute(attribute_name, '')
        end

        if options.key?(:for)
          belongs_to(options.delete(:for), options)
        end

        extend ClassMethodsOnActivation
        include InstanceMethodsOnActivation
      end
    end

    # Mixes class methods into the comment model.
    module ClassMethodsOnActivation

      # Labels the model as a comment.
      def acts_as_comment?
        true
      end
    end

    # Mixes instance methods into the model.
    module InstanceMethodsOnActivation

      # Writes the comment attribute.
      def write_comment_attribute(value)
        write_attribute(comment_attribute, value.to_s)
      end

      # Returns the comment attribute.
      def to_s
        send(comment_attribute).to_s
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsComment::ActsAsComment
