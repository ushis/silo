require 'pathname'
require 'securerandom'

# The Attachment model provides the ability to store uploaded files on
# the file system. It can be connected to any arbitrary model through the
# polymorphic _attachable_ association.
#
# Database scheme:
#
# - *id* integer
# - *attachable_id* integer
# - *attachable_type* string
# - *filename* string
# - *title* string
# - *created_at* datetime
# - *updated_at* datetime
class Attachment < ActiveRecord::Base
  attr_accessible :title

  after_destroy :unlink

  validates :filename, presence: true, uniqueness: true
  validates :title,    presence: true

  belongs_to :attachable, polymorphic: true

  # Directory name of the attachment store.
  DIRNAME = Pathname.new('attachments')

  # Absolute path to the attachment store.
  STORE = Rails.root.join(DIRNAME)

  # Inits a new Attachment from a file. The file is stored in the
  # attachment store and new Attachment is returned.
  #
  # Raises several exceptions on error.
  def self.from_file(file, title = nil)
    attachment = Attachment.new
    attachment.store(file)

    if ! title.blank?
      attachment.title = title
    elsif file.is_a? ActionDispatch::Http::UploadedFile
      attachment.title = file.original_filename
    else
      attachment.title = File.basename(file.path)
    end

    attachment
  rescue
    attachment.destroy
    raise
  end

  # An alias for Attachment.from_file. But it is taking a hash as argument.
  # The hash should include a _file_ and a _title_ key.
  def self.from_upload(params)
    from_file(params[:file], params[:title])
  end

  # Returns the file extension of the stored file.
  def ext
    File.extname(filename.to_s)
  end

  # Returns a nice filename generated from the title.
  def public_filename
    if (ext = File.extname(title)).blank?
      ext = File.extname(filename.to_s)
    end

    File.basename(title, ext).parameterize + ext
  end

  # Returns the absolute path to the stored file.
  def absolute_path
    STORE.join(filename.to_s)
  end

  # Stores the attachment on the filesystem and sets the filename.
  #
  #   attachment.store(upload)
  #   #=> 'e4b969da-10df-4374-afd7-648b15b09903.doc'
  #
  #   attachment.filename
  #   #=> 'e4b969da-10df-4374-afd7-648b15b09903.doc'
  #
  # Returns the filename.
  def store(attachment)
    case attachment
    when ActionDispatch::Http::UploadedFile
      ext = File.extname(attachment.original_filename)
    when File
      ext = File.extname(attachment.path)
    else
      raise TypeError, 'Argument must be a File or a UploadedFile.'
    end

    empty_file(ext.downcase) do |f|
      while (chunk = attachment.read(16384))
        f << chunk
      end

      self.filename = File.basename(f.path)
    end
  end

  private

  # Removes the attachment from the file system. Returns true on success,
  # else false.
  def unlink
    !!absolute_path.delete
  rescue
    false
  end

  # Opens a file with unique filename in _wb_ mode.
  #
  #   cv.empty_file('.doc')
  #   #=> <File:/path/to/store/e4b969da-10df-4374-afd7-648b15b09903.doc>
  def empty_file(suffix = nil)
    STORE.mkpath unless STORE.exist?
    date = Date.today.to_formatted_s(:db)

    begin
      path = STORE.join("#{date}-#{SecureRandom.uuid}#{suffix}")
    end while path.exist?

    if block_given?
      path.open('wb') { |f| yield(f) }
    else
      path.open('wb')
    end
  end
end
