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
  attr_accessible :file, :language_id

  validates :cv,          presence: true
  validates :language_id, presence: true

  has_one :attachment, autosave: true, dependent: :destroy, as: :attachable

  belongs_to :expert
  belongs_to :language

  delegate :absolute_path, :created_at, :ext, to: :attachment, allow_nil: true

  default_scope includes(:language)

  # Saves the record or destroys it on failure.
  #
  # It triggers all after_destroy callbacks, e.g. Attachment#unlink().
  def save_or_destroy
    success = save
    destroy unless success
    success
  end

  # Stores the file and loads its content into the cv attribute.
  def file=(file)
    build_attachment(file: file)
    load_document
  end

  # Assignes a language.
  def language_id=(id)
    self.language = Language.find_language(id)
  end

  # Returns the public filename of the cv document.
  #
  #   cv.public_filname
  #   #=> 'cv-arthur-hoffmann-en.doc'
  def public_filename
    "cv #{expert.full_name} #{language.language}".parameterize + ext.to_s
  end

  private

  # Loads the documents text and stores it in the cv attribute.
  #
  #   cv.load_document
  #   #=> 'Hello Silo,\n\nHow are you today?'
  #
  #   cv.cv
  #   #=> 'Hello Silo,\n\nHow are you today?'
  #
  # Returns the documents text.
  def load_document
    self.cv = Yomu.new(absolute_path).text
  rescue
    self.cv = nil
  end
end
