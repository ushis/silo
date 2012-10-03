module ArrayifiedParams
  extend ActiveSupport::Concern

  included do
    helper_method :arrayified_params
  end

  module InstanceMethods
    def arrayified_params
      @arrayified_params ||= ArrayifiedParams.new
    end
  end

  class ArrayifiedParams < ActiveSupport::HashWithIndifferentAccess
    def [](key)
      @cache[key] ||= case (value = params[key])
      when Array
        value
      when Hash
        value.values
      else
        value.to_s.split
      end
    end

    alias :fetch :[]
  end
end

ActionController::Base.send :include, ArrayifiedParams
