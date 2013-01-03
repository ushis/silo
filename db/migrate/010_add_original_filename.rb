class AddOriginalFilename < ActiveRecord::Migration
  def up
    add_column :attachments, :original_filename, :string

    Attachment.all.each do |a|
      a.title = File.basename(title, File.extname(filename))
      a.original_filename = a.filename
      a.save!(validate: false)
    end
  end

  def down
    remove_column :attachments, :original_filename
  end
end
