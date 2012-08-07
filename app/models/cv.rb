require 'yomu'

# The Cv model.
class Cv < ActiveRecord::Base
  attr_accessible :language

  has_one    :attachment, autosave: true, dependent: :destroy, as: :attachable
  belongs_to :experts

  # Inits a new Cv from a file. The file is stored on the filesystem and the
  # contents is stored in the _cv_ attribute.
  #
  #   if (cv = Cv.from_file(upload, params[:language]))
  #     expert.cvs << cv
  #   end
  #
  # Returns a new Cv object or nil on error.
  def self.from_file(document, language = :en)
    cv = Cv.new(language: language)

    if (cv.attachment = Attachment.from_file(document)) && cv.load_document
      return cv
    end

    cv.destroy
    nil
  end

  # Adds a fulltext search condition to the database query.
  #
  # Returns ActiveRecord:Relation.
  def self.search(query)
    where('MATCH (cvs.cv) AGAINST (?)', query)
  end

  # Tries to load the document text into the database.
  #
  # Returns the document text on success, else nil.
  def load_document
    unless (cv = Yomu.new(attachment.absolute_path).text).blank?
      self.cv = cv
    end
  rescue
    nil
  end

  # Loads the document text into the database and saves the record.
  #
  # Returns true on success.
  def load_document!
    load_document && save
  end
end
