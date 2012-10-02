# Adds symbolization of attributes to ActiveRecord. See
# Symbolize::ClassMethods.symbolize for more details.
module Symbolize
  extend ActiveSupport::Concern

  # Defines several helper methods, needed to symbolize attributes on read and
  # write. It should not be necessary to use them directly.
  module InstanceMethods

    # Symbolizes a value. Boolean and numeric values are preserved.
    #
    #   symbolize('hello')    #=> :hello
    #   symbolize('')         #=> nil
    #   smybolize(true)       #=> true
    #   symbolize(47)         #=> 47
    #   symbolize(Symbolize)  #=> nil
    #
    # Returns nil for empty strings and invlalid types.
    def symbolize(value)
      case value
      when String
        value.empty? ? nil : value.to_sym
      when Symbol, TrueClass, FalseClass, Numeric
        value
      else
        nil
      end
    end

    # Returns a symbolized attribute.
    def read_symbolized_attribute(attr_name)
      symbolize(read_attribute(attr_name))
    end

    # Symbolizes an attribute before writing it.
    def write_symbolized_attribute(attr_name, value)
      write_attribute(attr_name, symbolize(value))
    end
  end

  # Defines class methods to activate attribute symbolization.
  module ClassMethods

    # Initializes attribute symbolization. It takes the attribute name and
    # several options:
    #
    #   class User < ActiveRecord::Base
    #     symbolize :locale, in: [:en, :de, :cz], default: :en
    #   end
    #
    # Recognized options are:
    #
    # - *:in*           An array of possible values.
    # - *:default*      A default value, used in case of nil.
    # - *:validate*     Set to false, to disable validation.
    # - *:allow_nil*    Adds :allow_nil validation rule.
    # - *:allow_blank*  Adds :allow_blank validation rule.
    #
    # Several methods are defined and overwritten. The example above
    # (re)defines the following methods/constants:
    #
    #   User::LOCALES       # A constant array holding the possible values.
    #
    #   User.locale_values  # Returns a select box friendly list of all values.
    #   #=> [['English', :en], ['German', :de], ['Czech', :cz]]
    #
    #   user.locale=('de')  # Symbolizes and writes the locale attribute.
    #
    #   user.locale         # Reads an symbolizes the locale attribute.
    #   #=> :de
    #
    #   user.human_locale   # Returns the localized attribute
    #   #=> 'German'
    #
    # The I18n localization path is
    # *activerecord.symbolizes.model_name.attribute_name.value*:
    #
    #   ---
    #   en:
    #     activerecord:
    #       symbolizes:
    #         user:
    #           locale:
    #             en: 'English'
    #             de: 'German'
    #
    # The example also validates the inclusion of the attributes value in the
    # list of possible values before saving a record.
    def symbolize(attr_name, options = {})

      # Defines the getter method.
      define_method(attr_name) do
        read_symbolized_attribute(attr_name) || options[:default]
      end

      # Defines the setter method.
      define_method("#{attr_name}=") do |value|
        write_symbolized_attribute(attr_name, value)
      end

      return unless options[:in].is_a?(Array)

      const = ActiveSupport::Inflector.pluralize(attr_name.to_s).upcase.to_sym

      # Sets the list of possible values.
      unless const_defined?(const)
        const_set const, options[:in]
      end

      # Defines the localized getter method.
      define_method("human_#{attr_name}") do
        self.class.translate_symbolized_value(attr_name, send(attr_name))
      end

      method = "#{attr_name}_values".to_sym

      # Defines the class method returning the list of all values.
      self.class.instance_eval do
        unless method_defined?(method)
          define_method(method) do
            const_get(const).inject([]) do |values, sym|
              values << [translate_symbolized_value(attr_name, sym), sym]
            end
          end
        end
      end

      return if options[:validate] == false

      send(:validates, attr_name,
           inclusion: const_get(const),
           allow_nil: options[:allow_nil],
           allow_blank: options[:allow_blank])
    end

    # Translates a symbolized value. This method is used by the human_xxx
    # method. It should not be necessary to use this method directly.
    #
    #   User.translate_symbolized_value(:locale, :en)
    #   #=> 'English'
    #
    # Returns nil, if value is nil.
    def translate_symbolized_value(attr_name, value)
      unless value.nil?
        I18n.t(value, scope: [:activerecord, :symbolizes, model_name.i18n_key, attr_name])
      end
    end
  end
end

ActiveRecord::Base.send :include, Symbolize
