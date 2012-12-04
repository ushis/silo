require 'csv'

# Mixes AsCsv::ClassMethods#as_csv into ActiveRecord.
module AsCsv
  extend ActiveSupport::Concern

  # Implements the ClassMethods#as_csv method.
  module ClassMethods

    # Generates a CSV from a ActiveRecord::Relation. It uses
    # ExposableAttributes::ClassMethods#exposable_attributes to choose the
    # attributes to be exported.
    #
    #   class Article < ActiveRecord::Base
    #     attr_accessible :title, :sub_title, as: :exposable
    #   end
    #
    # To generate some CSV simply write something like this.
    #
    #   Article.limit(2).as_csv
    #
    #   # title,sub_title
    #   # Hello World,My First Article
    #   # Some Title,Just An Experiment
    #
    # Exporting associated records should be no problem too. Checkout the
    # following setup.
    #
    #   class Article < ActiveRecord::Base
    #     attr_accessible :title, :sub_title, as: :exposable
    #
    #     belongs_to :author
    #     has_and_belongs_to_many :tags
    #   end
    #
    #   class Tag < ActiveRecord::Base
    #     attr_accessible :tag, as: :exposable
    #
    #     has_and_belongs_to_many :articles
    #   end
    #
    #   class Author < ActiveRecord::Base
    #     attr_accessible :name, :email
    #
    #     has_many :articles
    #   end
    #
    # With the :include option it is possible to include associated records
    # into the export. For single record associations (:belongs_to, :has_one)
    # the data is simply appended to the rows.
    #
    #   Article.limit(2).as_csv(include: :author)
    #
    #   # title,sub_title,name,email
    #   # Hello World,My First Article,Bill Murray,bill@murray.com
    #   # Some Title,Just An Experiment,Peter Lustig,peter@lustig.de
    #
    # For multiple record associtations (:has_many, :has_and_belongs_to_many)
    # every associated record leads to a new row.
    #
    #   Article.limit(2).as_csv(include: :tags)
    #
    #   # title,sub_title,tag
    #   # Hello World,My First Article,hello
    #   # Hello World,My First Article,world
    #   # Hello World,My First Article,funny
    #   # Some Title,Just An Experiment,
    #
    # It is also possible to specify multiple includes.
    #
    #   Article.limit(2).as_csv(include: [:tags, :author])
    #
    #   # title,sub_title,tag,name,email
    #   # Hello World,My First Article,hello,Bill Murray,bill@murray.com
    #   # Hello World,My First Article,world,Bill Murray,bill@murray.com
    #   # Hello World,My First Article,funny,Bill Murray,bill@murray.com
    #   # Some Title,Just An Experiment,,Peter Lustig,peter@lustig.de
    #
    # To use it in your Controller you can write something like this.
    #
    #   def index
    #     @articles = Article.limit(10)
    #
    #     respond_to do |format|
    #       format.html
    #       format.csv { send_data @articles.as_csv(include: :author) }
    #     end
    #   end
    #
    # The method returns a string and raises a SecurityError if one of the
    # models has no exposable attributes. See
    # ExposableAttributes::ClassMethods#exposable_attributes for more info.
    #
    # ==== TODO:
    #
    # Add some sort of namespace to the column names to avoid name clashes.
    def as_csv(options = {}, csv_options = {})
      attributes = exposable_attributes
      associations = {}

      Array.wrap(options[:include]).each do |assoc|
        next unless (ref = reflect_on_association(assoc))

        class_name = (ref.options[:class_name] || ref.name).to_s.classify
        associations[assoc] = class_name.constantize.exposable_attributes
      end

      CSV::generate(csv_options) do |csv|
        csv << attributes + associations.values.flatten

        includes(associations.keys).all.each do |record|
          record_data = attributes.map { |attr| record.send(attr).to_s }

          associated_data = associations.map do |method, attrs|
            associated_records = Array.wrap(record.send(method))

            if associated_records.empty?
              next [Array.new(attrs.length)]
            end

            associated_records.map do |rec|
              attrs.map { |attr| rec.send(attr).to_s }
            end
          end

          [record_data].product(*associated_data).each do |row|
            csv << row.flatten
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, AsCsv
