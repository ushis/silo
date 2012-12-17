module AttachmentSpecHelper
  def self.included(base)
    base.before(:all) do
      @store = Rails.root.join(Rails.application.config.attachment_store)
      FileUtils.remove_entry_secure(@store) if @store.directory?
    end

    base.after(:all) do
      FileUtils.remove_entry_secure(@store) if @store.directory?
    end
  end

  def count_files(store)
    store.directory? ? store.children(false).length : 0
  end

  def fixture_file_path(filename)
    ::Rails.root.join('spec', 'fixtures', 'files', filename)
  end

  def fixture_file_upload(filename, type = nil)
    ::ActionDispatch::Http::UploadedFile.new({
      tempfile: open(fixture_file_path(filename)),
      filename: filename,
      type: type
    })
  end
end
