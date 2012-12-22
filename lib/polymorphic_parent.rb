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
    # To get the parent record:
    #
    #   user = find_parent
    #   #=> #<User id: 12>
    #
    # Thats it.
    def polymorphic_parent(*parents)
      class_attribute :polymorphic_parents

      self.polymorphic_parents = parents.map do |parent|
        [parent, parent.to_s.singularize.foreign_key]
      end

      include InstanceMethodsOnActivation
    end
  end

  # Defines the needed instance methods. Will be included on activation.
  module InstanceMethodsOnActivation

    # Returns a hash with info about the parent, extracted from the params.
    #
    # See PolymorphicParent::ClassMethods for more info.
    def parent
      @_parent_info ||= begin
        controller, key = polymorphic_parents.find { |_, key| params.include?(key) }

        {
          id: params[key],
          model: controller.to_s.classify.constantize,
          controller: controller,
          foreign_key: key
        }
      end
    end

    # Returns the parent record and triggers a redirect when not found. This
    # is nice as a before_filters.
    #
    # See PolymorphicParent::ClassMethods for more info.
    def find_parent(url = :back)
      @parent ||= parent[:model].find(parent[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
      redirect_to(url)
    end
  end
end

ActionController::Base.send :include, PolymorphicParent
