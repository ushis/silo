require 'yomu'

# The Cv model provides the ability to add cvs to the Expert model. The
# uploaded Cv is stored on the file system and its content is loaded into
# the database (using the yomu gem) to allow fast fulltext search.
#
# Database scheme:
#
# - *id* intger
# - *expert_id* integer
# - *language_id* integer
# - *cv* text
class Cv < ActiveRecord::Base
  has_one    :attachment, autosave: true, dependent: :destroy, as: :attachable
  belongs_to :expert
  belongs_to :language

  default_scope includes(:language)

  # Inits a new Cv from a file. The file is stored on the filesystem and the
  # contents is stored in the _cv_ attribute.
  #
  #   expert.cvs << Cv.from_file(upload, language))
  #
  # Returns a new Cv object and raises several exceptions on error.
  def self.from_file(file, language)
    cv = Cv.new
    cv.attachment = Attachment.from_file(file)
    cv.load_document!
    cv.language = Language.find_language(language)
    cv
  rescue
    cv.destroy
    raise
  end

  # Takes a Hash containing a :file and a :language_id key and passes it to
  # Cv.from_file.
  def self.from_upload(data)
    from_file(data[:file], data[:language_id])
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
    "cv #{expert.full_name} #{language.language}".parameterize + ext
  end

  # Returns the documents file extension.
  def ext
    attachment.try(:ext)
  end

  # Returns the absolute path to the stored cv document.
  def absolute_path
    attachment.try(:absolute_path)
  end

  # Returns the created_at attribute of the cvs attachment.
  def created_at
    attachment.try(:created_at)
  end

  # Tries to load the document text.
  #
  # Returns the document text on success, raise an exception on error.
  def load_document
    if (text = Yomu.new(absolute_path).text).blank?
      raise 'Empty document'
    else
      text
    end
  end

  # Loads the document and stores the returned text in the cv attribute.
  def load_document!
    self.cv = load_document
  end
end
