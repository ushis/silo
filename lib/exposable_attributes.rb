# The ExposableAttributes module mixes the exposable_attributes method
# into ActiveRecord.
module ExposableAttributes
  extend ActiveSupport::Concern

  # Defines the exposable_attributes method.
  module ClassMethods

    # Returns an Array of exposable attributes to filter attribute names from
    # untrusted sources or to define a safe exposable subset of the models
    # attributes.
    #
    #   class Post < ActiveRecord::Base
    #     attr_accessible :title, :body, :published, as: :exposable
    #
    #     def human_published
    #       I18n.translate published?.to_s, scope: [:values, :boolean]
    #     end
    #   end
    #
    # The method handles some filter options.
    #
    #   Post.exposable_attribtues
    #   #=> ["title", "body", "private"]
    #
    #   Post.exposable_attributes(only: [:title, :user_id])
    #   #=> ["body"]
    #
    #   Post.exposable_attributes(exclude: :body)
    #   #=> ["title", "private"]
    #
    #   Post.exposable_attributes(human: true, exclude: [:body])
    #   #=> [["title", "title"], ["published", "human_published"]]
    #
    # This is useful to filter attribute names from untrusted sources.
    #
    #   attributes = Post.exposable_attributes(only: params[:attributes])
    #
    #   CSV::generate do |csv|
    #     csv << attributes
    #
    #     category.posts.each do |post|
    #       csv << post.values_at(attributes)
    #     end
    #   end
    #
    # If a model has no exposable attributes, a SecurityError is raised.
    def exposable_attributes(options = {})
      unless attr_accessible.key?(:exposable)
        raise SecurityError, 'This model has no exposable attributes.'
      end

      attributes = attr_accessible[:exposable]

      if (only = options[:only])
        attributes &= Array.wrap(only).map(&:to_s)
      elsif (except = options[:except])
        attributes -= Array.wrap(except).map(&:to_s)
      end

      unless options[:human]
        return attributes.to_a
      end

      attributes.map do |attr|
        [attr, method_defined?("human_#{attr}") ? "human_#{attr}" : attr]
      end
    end
  end
end

ActiveRecord::Base.send :include, ExposableAttributes
