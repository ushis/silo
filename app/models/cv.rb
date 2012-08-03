require 'pathname'
require 'securerandom'
require 'yomu'

# The Cv model.
class Cv < ActiveRecord::Base
  attr_accessible :language

  after_destroy :delete_document

  belongs_to :experts

  # Filename prefix.
  PREFIX = 'cv-'

  # Directory name of the cv store.
  DIRNAME = Pathname.new('cvs')

  # Absolute path to the cv store.
  STORE = Rails.root.join('public', DIRNAME)

  # Returns the absolute path to the cv document.
  def absolute_path
    STORE.join(filename)
  end

  # Returns the path to the document download.
  def download_path
    DIRNAME.join(filename)
  end

  # Stores the document in the CV store and sets the filename.
  #
  #   cv.store_document(upload)
  #   #=> 'cv-e4b969da-10df-4374-afd7-648b15b09903.doc'
  #
  #   cv.filename
  #   #=> 'cv-e4b969da-10df-4374-afd7-648b15b09903.doc'
  #
  # Returns the filename.
  def store_document(document)
    if document.is_a? ActionDispatch::Http::UploadedFile
      ext = File.extname(document.original_filename)
    elsif document.is_a? File
      ext = File.extname(document.path)
    elsif document.is_a? String
      ext = File.extname(document)
      document = File.open(document, 'rb')
    else
      raise ArgumentError, 'Argument must be File, UploadedFile or String.'
    end

    empty_document(ext) do |f|
      f << document.read
      self.filename = File.basename(f.path)
    end
  end

  # Tries to load the document text into the database.
  #
  # Returns the document text on success, else nil.
  def load_document
    self.cv = Yomu.new(absolute_path).text
  rescue
    nil
  end

  # Loads the document text into the database and saves the record.
  #
  # Returns true on success.
  def load_document!
    load_document && save
  end

  # Deletes the CV document.
  def delete_document
    if absolute_path.file?
      absolute_path.delete
    end
  end

  private

  # Opens a document with unique filename in _wb_ mode.
  #
  #   cv.empty_document('.doc')
  #   #=> <File:/path/to/store/cv-e4b969da-10df-4374-afd7-648b15b09903.doc>
  def empty_document(suffix = nil)
    begin
      path = STORE.join("#{PREFIX}#{SecureRandom.uuid}#{suffix}")
    end while path.exist?

    if block_given?
      File.open(path, 'wb') { |f| yield(f) }
    else
      File.open(path, 'wb')
    end
  end
end
