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
    # Now the parent method is available in the controller:
    #
    #   # URL: /users/12/attachments/7
    #
    #   parent
    #   #=> {
    #   #     id: 12,
    #   #     model: User(id: integer, ...),
    #   #     controller: :users,
    #   #     foreign_key: :user_id
    #   #   }
    #
    # Thats it.
    def polymorphic_parent(*parents)
      parents = parents.map { |p| [p, p.to_s.singularize.foreign_key] }

      # Returns a hash with basic information about the parent.
      define_method(:parent) do
        @parent ||= begin
          controller, key = parents.find { |_, key| params.include?(key) }

          {
            id: params[key],
            model: controller.to_s.classify.constantize,
            controller: controller,
            foreign_key: key
          }
        end
      end
    end
  end
end

ActionController::Base.send :include, PolymorphicParent
