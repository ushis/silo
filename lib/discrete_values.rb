# Mixes support for discrete values into ActiveRecord.
#
# To define discrete values for an attribute you can write:
#
#   class User < ActiveRecord::Base
#     discrete_values :locale, [:en, :de, :fr], default: :de
#   end
#
# This defines some possible values for the locale attribute. It also adds
# validation, a before_save callback to set the default value (when specified)
# and additional methods:
#
#   # All values in a select box friendly format.
#   User.locale_values
#   #=> [['English', 'en'], ['German', 'de'], ['French', 'fr']]
#
#   # I18n
#   user.locale        #=> 'de'
#   user.human_locale  #=> 'German'
#
# === Options
#
# - *:default*  Sets the default value before save, when it is nil.
# - *:validate*  Set to false to disable validation.
# - *:allow_blank*  Passed to the validation.
# - *:allow_nil*  Passed to the validation.
# - *:i18n_scope*  Use a custom i18n scope.
#
# === I18n
#
# The default search paths are:
#
# - activerecord.discrete.{model}.{attribute}.{value}
# - activerecord.discrete.values.{attribute}.{value}
#
# Example of a working en.yml:
#
#   ---
#   en:
#     activerecord:
#       discrete:
#         values:
#           size:
#             s: 'Small'
#             m: 'Medium'
#             l: 'Large'
#         user:
#           locale:
#             en: 'English'
#             de: 'German'
#             fr: 'French'
#
# These paths can be overriden with the *:i18n_scope* option.
module DiscreteValues
  extend ActiveSupport::Concern

  # Defines ClassMethods#discrete_values
  module ClassMethods

    # Defines discrete values for an attribute.
    #
    # See the DiscreteValues module for more info.
    def discrete_values(attribute_name, values, options = {})
      extend ClassMethodsOnActivation
      include InstanceMethodsOnActivation

      unless respond_to?(:_discrete_values)
        class_attribute(:_discrete_values)
        self._discrete_values = {}
      end

      _discrete_values[attribute_name] = {
        values: values.map { |v| convert_discrete_value(v) },
        default: convert_discrete_value(options[:default]),
        i18n_scope: options[:i18n_scope]
      }

      define_singleton_method("#{attribute_name}_values") do
        discrete_values_for(attribute_name)
      end

      define_method(attribute_name) do
        read_discrete_value_attribute(attribute_name)
      end

      define_method("#{attribute_name}=") do |value|
        write_discrete_value_attribute(attribute_name, value)
      end

      define_method("set_default_#{attribute_name}") do
        set_default_discrete_value_for(attribute_name)
      end

      define_method("human_#{attribute_name}") do
        human_discrete_value(attribute_name)
      end

      if options.key?(:default)
        before_save("set_default_#{attribute_name}")
      end

      if options.fetch(:validate, true)
        validation_options = options.slice(:allow_nil, :allow_blank)
        validation_options[:inclusion] = _discrete_values[attribute_name][:values]
        validates(attribute_name, validation_options)
      end
    end
  end

  # Mixes class methods into the model.
  module ClassMethodsOnActivation

    # Converts the value.
    def convert_discrete_value(value)
      value.is_a?(Symbol) ? value.to_s : value
    end

    # Returns all possible values for an attribute in a select box friendly
    # format.
    def discrete_values_for(attribute_name)
      _discrete_values[attribute_name][:values].map do |value|
        [human_discrete_value(attribute_name, value), value]
      end
    end

    # Returns value in a human readable format.
    def human_discrete_value(attribute_name, value)
      return nil if value.nil?

      scope = _discrete_values[attribute_name][:i18n_scope]

      keys = []
      keys << :"#{scope}.#{value}" if scope
      keys << :"#{i18n_scope}.discrete.#{model_name.i18n_key}.#{attribute_name}.#{value}"
      keys << :"#{i18n_scope}.discrete.values.#{attribute_name}.#{value}"

      I18n.t(keys.shift, default: keys)
    end
  end

  # Mixes instance methods into the model.
  module InstanceMethodsOnActivation

    # Sets the default value if it is empty.
    def set_default_discrete_value_for(attribute_name)
      if read_attribute(attribute_name).nil?
        write_attribute(attribute_name, _discrete_values[attribute_name][:default])
      end
    end

    # Returns the value or the default if its empty.
    def read_discrete_value_attribute(attribute_name)
      read_attribute(attribute_name) || _discrete_values[attribute_name][:default]
    end

    # Converts and assigns the value.
    def write_discrete_value_attribute(attribute_name, value)
      write_attribute(attribute_name, self.class.convert_discrete_value(value))
    end

    # Returns the value of the attribute in a human readable format.
    def human_discrete_value(attribute_name)
      self.class.human_discrete_value(attribute_name, read_discrete_value_attribute(attribute_name))
    end
  end
end

ActiveRecord::Base.send :include, DiscreteValues
