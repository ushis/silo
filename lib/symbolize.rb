# Adds symbolization of attributes to ActiveRecord. See
# Symbolize::ClassMethods.symbolize for more details.
module Symbolize
  extend ActiveSupport::Concern

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
    # - *:i18n_scope*   Use a custom i18n scope for translations.
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
    #   user.human_locale   # Returns the localized attribute.
    #   #=> 'German'
    #
    #   user.set_default_locale  # Sets the default locale.
    #   #=> :en
    #
    # The default I18n localization paths are:
    #
    # - activerecord.symbolizes.{model_name}.{attribute_name}.{value}
    # - activerecord.symbolizes.values.{attribute_name}.{value}
    #
    # Example of a working en.yml:
    #
    #   ---
    #   en:
    #     activerecord:
    #       symbolizes:
    #         values:
    #           sizes:
    #             s: 'Small'
    #             m: 'Medium'
    #             l: 'Large'
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
      define_method(:"#{attr_name}=") do |value|
        write_symbolized_attribute(attr_name, value)
      end

      # Defines the set_default_xxx method and adds a before_save callback.
      unless options[:default].nil?
        define_method(:"set_default_#{attr_name}") do
          if read_symbolized_attribute(attr_name).nil?
            write_symbolized_attribute(attr_name, options[:default])
          end
        end

        send(:before_save, :"set_default_#{attr_name}")
      end

      return unless options[:in].is_a?(Array)

      const = ActiveSupport::Inflector.pluralize(attr_name.to_s).upcase.to_sym

      # Sets the list of possible values.
      unless const_defined?(const)
        const_set const, options[:in]
      end

      # Defines the localized getter method.
      define_method(:"human_#{attr_name}") do
        self.class.translate_symbolized_value(attr_name, send(attr_name), options[:i18n_scope])
      end

      # Defines the class method returning the list of all values.
      define_singleton_method(:"#{attr_name}_values") do
        const_get(const).collect do |sym|
          [translate_symbolized_value(attr_name, sym, options[:i18n_scope]), sym]
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
    def translate_symbolized_value(attr_name, value, scope = nil)
      return nil if value.nil?

      keys = [
        :"#{i18n_scope}.symbolizes.#{model_name.i18n_key}.#{attr_name}.#{value}",
        :"#{i18n_scope}.symbolizes.values.#{attr_name}.#{value}"
      ]

      if scope
        scope = scope.join('.') if scope.is_a?(Array)
        keys.unshift(:"#{scope}.#{value}")
      end

      I18n.t(keys.shift, default: keys)
    end
  end
end

ActiveRecord::Base.send :include, Symbolize
