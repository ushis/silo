require 'set'

# The BodyClass module defines the BodyClass class and a helper method to
# work with body classes. The idea is to write something like this in the
# controller.
#
#   class PostsController < ApplicationController
#     def show
#       @post = Post.find(params[:id])
#       body_class << @post.type
#     end
#   end
#
# And this in the layout template.
#
#   <body class="<%= body_class %>">
#
# The BodyClass behaves like a Set with indifferent access, which means that
# that Symbols are internally converted into Strings.
#
#   body_class = BodyClass::BodyClass.new(:example)
#   #=> #<BodyClass::BodyClass {'example'}>
#
#   body_class.include?(:example)   #=> true
#   body_class.include?('example')  #=> true
#
# There are two more differences to a normal Set.
#
# - BodyClass::BodyClass#delete() returns the deleted value or nil.
# - BodyClass::BodyClass#to_s returns all values joined by a space.
#
# Some examples.
#
#   body_class = BodyClass::BodyClass.new([:example, :admin])
#
#   body_class.to_s              #=> 'example admin'
#   body_class.delete(:example)  #=> 'example'
#   body_class.delete(:x)        #=> nil
#
# Much fun!
module BodyClass

  # Handles the body class. See the ::BodyClass module for more info.
  class BodyClass < Set

    # Initializes the body class.
    def initialize(enum = nil, &block)
      @hash ||= HashWithIndifferentAccess.new

      super(enum, &block)
    end

    # Deletes a value from the body class.
    #
    # Returns the value as a string or nil if it is not present.
    def delete(value)
      @hash.delete(value) && @hash.send(:convert_key, value)
    end

    # Returns all body class values as a string joined by a space.
    def to_s
      to_a.join(' ')
    end
  end

  # Defines some helper methods.
  module ActionController
    extend ActiveSupport::Concern

    included { helper_method(:body_class) }

    # Returns the body class.
    def body_class
      @body_class ||= begin
        values = params.values_at(:controller, :action)

        BodyClass.new(values.map { |v| v.to_s.dasherize })
      end
    end
  end
end

ActionController::Base.send :include, BodyClass::ActionController
