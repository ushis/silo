# Mixes missing methods into active record.
module ActiveRecordHelpers
  extend ActiveSupport::Concern

  # Additional class methods.
  module ClassMethods

    # Filters associations from an array of attributes/association names.
    #
    #   class Article < ActiveRecord::Base
    #     belongs_to :category
    #     has_and_belongs_to_many :tags
    #   end
    #
    #   Article.filter_associations([:title, :body, :tags, :category])
    #   #=> [:tags, :category]
    #
    # Returns an array of association names.
    def filter_associations(names)
      names.map(&:to_sym) & reflect_on_all_associations.map(&:name)
    end

    # Checks if the model has a association.
    #
    #   Article.association?(:tags)  #=> true
    #
    # Returns true if the passed value is an association name, else false.
    def association?(name)
      ! reflect_on_association(name.to_sym).nil?
    end

    # Checks if the model has a belongs_to association.
    #
    #   Article.belongs_to?(:category)  #=> true
    #
    # Returns true if the model has a belongs_to association of the specified
    # name, else false.
    def belongs_to?(name)
      association_of_macro?(name, :belongs_to)
    end

    # Checks if the model has a has_one association.
    #
    #   Article.has_one?(:category)  #=> false
    #
    # Returns true if the model has a has_one association of the specified
    # name, else false.
    def has_one?(name)
      association_of_macro?(name, :has_one)
    end

    # Checks if the model has a has_many association.
    #
    #   Article.has_many?(:tags)  #=> false
    #
    # Returns true if the model has a has_many association of the specified
    # name else false.
    def has_many?(name)
      association_of_macro?(name, :has_many)
    end

    # Checks if the model has a has_and_belongs_to_many association.
    #
    #   Article.has_and_belongs_to_many?(:tags)  #=> true
    #
    # Returns true if the model has a has_and_belongs_to_many association of
    # the specified name else false.
    def has_and_belongs_to_many?(name)
      association_of_macro?(name, :has_and_belongs_to_many)
    end

    private

    # Checks if the model has a association of specific macro.
    #
    #   Article.association_of_macro?(:category, :belongs_to)  #=> true
    #
    # Returns true if the model has a association of the specified name and
    # macro else false.
    def association_of_macro?(name, macro)
      reflect_on_association(name.to_sym).try(:macro) == macro
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecordHelpers
