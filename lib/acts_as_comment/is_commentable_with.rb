module ActsAsComment
  module IsCommentableWith
    extend ActiveSupport::Concern

    # Defines ClassMethods#is_commentable_with
    #
    # See ActsAsComment for more info.
    module ClassMethods

      # Makes model commentable with one or more comment models.
      def is_commentable_with(assoc, options = {})
        attr_accessible(assoc)

        klass = has_one(assoc, options).klass

        unless klass.respond_to?(:acts_as_comment?) && klass.acts_as_comment?
          raise NotAComment, klass.name
        end

        define_method(assoc) do |reload = false|
          super(reload) || association(assoc).writer(klass.new)
        end

        define_method("#{assoc}=") do |value|
          if value.is_a?(klass)
            super(value)
          else
            send(assoc).write_comment_attribute(value)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsComment::IsCommentableWith
