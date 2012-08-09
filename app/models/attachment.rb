require 'pathname'
require 'securerandom'

# The Attachment model.
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
  # attachment store and new Attachment is returned... or nil on
  # error.
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
    nil
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
    if attachment.is_a? ActionDispatch::Http::UploadedFile
      ext = File.extname(attachment.original_filename)
    elsif attachment.is_a? File
      ext = File.extname(attachment.path)
    else
      raise ArgumentError, 'Argument must be a File or a UploadedFile.'
    end

    empty_document(ext.downcase) do |f|
      f << attachment.read
      self.filename = File.basename(f.path)
    end
  end

  private

  # Removes the attachment from the file system.
  def unlink
    if absolute_path.file?
      absolute_path.delete
    end
  end

  # Opens a document with unique filename in _wb_ mode.
  #
  #   cv.empty_document('.doc')
  #   #=> <File:/path/to/store/e4b969da-10df-4374-afd7-648b15b09903.doc>
  def empty_document(suffix = nil)
    STORE.mkpath unless STORE.exist?

    begin
      path = STORE.join("#{SecureRandom.uuid}#{suffix}")
    end while path.exist?

    if block_given?
      File.open(path, 'wb') { |f| yield(f) }
    else
      File.open(path, 'wb')
    end
  end
end
