module ActsAsTag
  module IsTaggableWith
    extend ActiveSupport::Concern

    # Defines ClassMethods#is_taggable_with
    #
    # See ActsAsTag for more info.
    module ClassMethods

      # Makes a model taggable with one or more tag models.
      def is_taggable_with(assoc, options = {})
        options[:uniq] = options.fetch(:uniq, true)

        attr_accessible(assoc)

        klass = has_and_belongs_to_many(assoc, options).klass

        unless klass.respond_to?(:acts_as_tag?) && klass.acts_as_tag?
          raise NotATag, klass.name
        end

        define_method("#{assoc}=") do |tags|
          super(tags.is_a?(String) ? klass.from_s(tags) : tags)
        end

        define_method("human_#{assoc}") do
          send(assoc).map(&:to_s).join(', ')
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsTag::IsTaggableWith
