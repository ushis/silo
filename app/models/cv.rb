require 'yomu'

# The Cv model.
class Cv < ActiveRecord::Base
  has_one    :attachment, autosave: true, dependent: :destroy, as: :attachable
  belongs_to :expert
  belongs_to :language

  default_scope includes(:attachment, :language)

  # Inits a new Cv from a file. The file is stored on the filesystem and the
  # contents is stored in the _cv_ attribute.
  #
  #   if (cv = Cv.from_file(upload))
  #     cv.language = Language.find_by_language('en')
  #     expert.cvs << cv
  #   end
  #
  # Returns a new Cv object or nil on error.
  def self.from_file(document)
    cv = Cv.new

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

  # Returns the public filename of the cv document.
  #
  #   cv.public_filname
  #   #=> 'cv-arthur-hoffmann-en.doc'
  def public_filename
    "cv #{expert.prename} #{expert.name} #{language.language}".parameterize +
      attachment.try(:ext)
  end

  # Returns the absolute path to the stored cv document.
  def absolute_path
    attachment.try(:absolute_path)
  end

  def created_at
    attachment.try(:created_at)
  end

  # Tries to load the document text into the database.
  #
  # Returns the document text on success, else nil.
  def load_document
    unless (cv = Yomu.new(absolute_path).text).blank?
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
