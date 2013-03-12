require 'csv'

# Generates a CSV from a ActiveRecord::Relation. It uses
# ExposableAttributes::ClassMethods#exposable_attributes to choose the
# attributes to be exported.
#
#   class Article < ActiveRecord::Base
#     attr_exposable :title, :sub_title, as: :csv
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
#     attr_exposable :title, :sub_title, as: :csv
#
#     belongs_to :author
#     has_and_belongs_to_many :tags
#   end
#
#   class Tag < ActiveRecord::Base
#     attr_exposable :tag, as: :csv
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
# AsCSV::ActiveRecord::ClassMethods#as_csv returns a string or raises a
# SecurityError if one of the models has no exposable attributes. See
# ExposableAttributes::ClassMethods#exposable_attributes for more info.
module AsCsv

  # Generates the CSV from a ::ActiveRecord::Relation.
  class Generator

    # Inits a new Generator. Recognizes the options :only, :except, :inlcude.
    #
    #   AsCsv::Generator.new(User.limit(2), only: :username, include: :posts)
    #
    # See ExposableAttributes for info about the options.
    def initialize(scope, options = {})
      @scope, @includes, @attributes = scope, {}, []

      includes(*options[:include])
      attributes(*scope.exposable_attributes(:csv, options.slice(:only, :except)))
    end

    # Adds associations to the CSV.
    #
    #   generator.includes :comments, :tags
    #
    # Invalid associations were ignored.
    def includes(*associations)
      associations.each do |association|
        if (reflection = @scope.reflect_on_association(association))
          @includes[association] = reflection.klass.exposable_attributes(:csv)
          @scope = @scope.includes(association)
        end
      end
    end

    # Adds attributes to the CSV.
    #
    #  generator = AsCsv::Generator.new(User, only: :username)
    #
    #  generator.attributes :email, :created_at
    #  #=> [:username, :email, :created_at]
    #
    # Returns an Array of all included attribtues.
    def attributes(*attributes)
      @attributes.concat(attributes)
      @scope = @scope.includes(@scope.filter_associations(attributes))
    end

    # Generates the Csv. Takes a hash of CSV specific options.
    #
    # See the CSV module for more info.
    def generate(options = {})
      CSV::generate(options) do |csv|
        csv << headers

        @scope.each do |record|
          rows_for(record) { |row| csv << row.flatten }
        end
      end
    end

    private

    # Returns the Csv headers.
    def headers
      @attributes + @includes.values.flatten
    end

    # This method builds the rows for a single record.
    #
    # You should override this, if you are not happy with the default behavior.
    def rows_for(record, &block)
      [row_for(record)].product(*associated_rows_for(record), &block)
    end

    # Builds the associated rows for a record.
    #
    # Returns a 3 level deep nested Array.
    def associated_rows_for(record)
      @includes.map do |method, attributes|
        associated_rows(Array.wrap(record.send(method)), attributes)
      end
    end

    # Builds the rows for the records of a single association.
    #
    # Returns a 2 level deep nested Array.
    def associated_rows(records, attributes)
      if records.empty?
        [Array.new(attributes.length)]
      else
        records.map { |record| row_for(record, attributes) }
      end
    end

    # Builds the row for a single record.
    #
    # Returns an Array.
    def row_for(record, attributes = @attributes)
      attributes.map { |attr| record.send(attr).to_s }
    end
  end

  # Mixin for ::ActiveRecord. See AsCsv for more info.
  module ActiveRecord
    extend ActiveSupport::Concern

    # Implements ClassMethods#as_csv. See AsCsv for more info.
    module ClassMethods

      # Generates a CSV from a ::ActiveRecord::Relation.
      #
      # See AsCsv for more info.
      def as_csv(options = {}, csv_options = {})
        Generator.new(scoped, options).generate(csv_options)
      end
    end
  end
end

ActiveRecord::Base.send :include, AsCsv::ActiveRecord
