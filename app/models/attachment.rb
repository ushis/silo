require 'pathname'
require 'securerandom'

# The Attachment model provides the ability to store uploaded files on
# the file system. It can be connected to any arbitrary model through the
# polymorphic _attachable_ association.
#
# Database scheme:
#
# - *id:*                 integer
# - *attachable_id:*      integer
# - *attachable_type:*    string
# - *filename:*           string
# - *original_filename:*  string
# - *title:*              string
# - *created_at:*         datetime
# - *updated_at:*         datetime
#
# The attributes *filename* and *original_filename* must be present. The
# *title* attribute is populated before save, if it is blank.
class Attachment < ActiveRecord::Base
  attr_accessible :title, :file

  before_save :set_title

  after_destroy :unlink

  validates :filename,          presence: true, uniqueness: true
  validates :original_filename, presence: true

  validates_with FileExistsValidator

  belongs_to :attachable, polymorphic: true

  # Directory name of the attachment store.
  DIRNAME = Rails.application.config.attachment_store

  # Absolute path to the attachment store.
  STORE = Rails.root.join(DIRNAME)

  # Saves the record or destroys it on failure.
  #
  # It triggers all after_destroy callbacks, e.g. Attachment#unlink().
  def save_or_destroy
    success = save
    destroy unless success
    success
  end

  # Sets the title from the original filename if it is blank.
  def set_title
    self.title = File.basename(original_filename.to_s, ext) if title.blank?
  end

  # Stores the file.
  def file=(file)
    store(file)
  rescue IOError, SystemCallError
    unlink
  end

  # Returns the file extension of the stored file.
  def ext
    File.extname(original_filename.to_s).downcase
  end

  # Returns a nice filename generated from the title.
  def public_filename
    File.basename(title, ext).parameterize + ext
  end

  # Returns the absolute path to the stored file.
  def absolute_path
    STORE.join(filename.to_s)
  end

  private

  # Stores the attachment on the filesystem, sets filename
  # and original_filename.
  #
  #   attachment.store(upload)
  #
  #   attachment.filename
  #   #=> 'e4b969da-10df-4374-afd7-648b15b09903.doc'
  #
  #   attachment.original_filename
  #   #=> 'my-cv.doc'
  #
  # Raises IOError and SystemCallError on failure.
  def store(file)
    case file
    when ActionDispatch::Http::UploadedFile
      self.original_filename = file.original_filename
    when File
      self.original_filename = File.basename(file.path)
    else
      raise TypeError, 'Argument must be a File or a UploadedFile.'
    end

    empty_file(ext) do |f|
      self.filename = File.basename(f.path)
      IO.copy_stream(file, f)
    end
  end

  # Opens a file with unique filename in _wb_ mode.
  #
  #   cv.empty_file('.doc')
  #   #=> <File:/path/to/store/e4b969da-10df-4374-afd7-648b15b09903.doc>
  #
  # Raises IOError and SystemCallError on failure.
  def empty_file(suffix = nil, &block)
    date = Date.today.to_formatted_s(:db)

    begin
      path = STORE.join("#{date}-#{SecureRandom.uuid}#{suffix}")
    end while path.exist?

    STORE.mkpath unless STORE.exist?

    path.open('wb', &block)
  end

  # Removes the attachment from the file system.
  #
  # Returns true on success, else false.
  def unlink
    !! absolute_path.delete
  rescue
    false
  end
end
