# The ExposableAttributes module mixes the exposable_attributes method
# into ActiveRecord.
#
# With exposable attributes it is possible to define read access for specific
# profiles, such as PDF or CSV.
#
# They are defined with ExposableAttributes::ClassMethods#attr_exposable...
#
#   class Post < ActiveRecord::Base
#     attr_exposable :title, :body, :published, as: :csv
#
#     def human_published
#       I18n.translate published?.to_s, scope: [:values, :boolean]
#     end
#   end
#
# ...and can be retrieved with
# ExposableAttributes::ClassMethods#exposable_attributes.
#
# The method handles some filter options.
#
#   Post.exposable_attribtues(:csv)
#   #=> ["title", "body", "published"]
#
#   Post.exposable_attributes(:csv, only: [:title, :user_id])
#   #=> ["title"]
#
#   Post.exposable_attributes(:csv, exclude: :body)
#   #=> ["title", "published"]
#
#   Post.exposable_attributes(:csv, human: true, exclude: [:body])
#   #=> [["title", "title"], ["published", "human_published"]]
#
# This is useful to filter attribute names from untrusted sources.
#
#   attributes = Post.exposable_attributes(:csv, only: params[:attributes])
#
#   CSV::generate do |csv|
#     csv << attributes
#
#     category.posts.each do |post|
#       csv << post.values_at(attributes)
#     end
#   end
#
# It falls back to the *:default* profile, when no profile is specified.
module ExposableAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :_exposable_attributes
  end

  # Defines the exposable_attributes method.
  module ClassMethods

    # Defines exposable attributes. See the ExposableAttributes module for
    # more info.
    def attr_exposable(*attrs)
      options = attrs.extract_options!

      self._exposable_attributes = exposable_attributes_config

      Array.wrap(options.fetch(:as, :default)).each do |role|
        self._exposable_attributes[role] += attrs.map(&:to_s)
      end

      self._exposable_attributes
    end

    # Retrieves exposable attributes for a specified profile. See the
    # ExposableAttributes module for more info.
    def exposable_attributes(role = :default, options = {})
      attributes = self._exposable_attributes[role]

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

    private

    # Helper to init the models exposable attributes hash.
    def exposable_attributes_config
      self._exposable_attributes ||= Hash.new { |hsh, key| hsh[key] = Set.new }
    end
  end
end

ActiveRecord::Base.send :include, ExposableAttributes
