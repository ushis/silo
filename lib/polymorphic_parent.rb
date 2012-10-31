# The PolymorphicParent module is useful for nested resources with polymorphic
# parents. The PolymorphicParent::ClassMethods#polymorphic_parent method
# initliazes some methods to provide useful information about the parent
# classes/controllers.
module PolymorphicParent
  extend ActiveSupport::Concern

  # Defines the ClassMethods#polymorphic_parent method.
  module ClassMethods

    # Initializes method definitions for controllers with polymorphic
    # parents and nested resources.
    #
    #   class AttachmentsController < ApplicationController
    #
    #     # Sets the possible parents.
    #     polymorphic_parent :user, :galleries
    #   end
    #
    # Several methods were defined, such as:
    #
    #   # URL: /users/12/attachments/7
    #
    #   parent
    #   #=> { controller: :users, model: User(id: integer, ...), id: 12 }
    #
    #   parent_url
    #   #=> { controller: :users, action: :show, id: 12 }
    #
    #   parents_url
    #   #=> { controller: :users, action: :index }
    #
    # Thats it.
    def polymorphic_parent(*parents)
      parents = Hash[parents.map { |p| [p, p.to_s.singularize.foreign_key] }]

      # Returns a hash with basic information about the parent.
      define_method(:parent) do
        return @parent if @parent

        controller, key = parents.find { |_, key| params.include?(key) }

        @parent = {
          id: params[key],
          model: controller.to_s.classify.constantize,
          controller: controller,
          foreign_key: key
        }
      end
    end
  end
end

ActionController::Base.send :include, PolymorphicParent
