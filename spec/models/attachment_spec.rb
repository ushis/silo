require 'spec_helper'

describe Attachment do
  include AttachmentSpecHelper

  context 'validations' do
    [:filename, :title].each do |attr|
      it "must have a #{attr}" do
        attachment = Attachment.new
        attachment.should_not be_valid
        attachment.errors[attr].should_not be_empty
      end
    end

    it 'must have a unique filename' do
      filename = 'xyz.pdf'
      create(:attachment, filename: filename)

      attachment = build(:attachment, filename: filename)
      attachment.should_not be_valid
      attachment.errors[:filename].should_not be_empty
    end
  end

  context 'associations' do
    it { should belong_to(:attachable) }
  end

  describe :after_destroy do
    it 'should remove the attachment' do
      a = Attachment.from_file(fixture_file_upload('kittens.jpg'))
      a.save

      expect(a.absolute_path).to be_file
      expect { a.destroy }.to change { count_files(Attachment::STORE) }.by(-1)
      expect(a.absolute_path).to_not be_exist
    end
  end

  describe 'DIRNAME' do
    it 'should be the dirname for the attachment store defined in the config' do
      Attachment::DIRNAME.should == @store.basename.to_s
    end
  end

  describe 'STORE' do
    it 'should be the absolute path to the attachment store' do
      Attachment::STORE.should == @store
    end
  end

  describe 'from_file' do
    it 'should store the file' do
      filename = 'kittens.jpg'
      attachment = nil

      expect {
        attachment = Attachment.from_file(fixture_file_upload(filename))
      }.to change { count_files(Attachment::STORE) }.by(1)

      attachment.should be_a(Attachment)
      attachment.absolute_path.should be_a(Pathname)
      attachment.absolute_path.should be_file
      FileUtils.identical?(fixture_file_path(filename), attachment.absolute_path).should be_true
    end

    it 'should be valid' do
      attachment = Attachment.from_file(fixture_file_upload('kittens.jpg'))
      attachment.should be_valid
    end

    it 'should set the title from the original filename if not given' do
      attachment = Attachment.from_file(fixture_file_upload('kittens.jpg'))
      attachment.title.should == 'kittens.jpg'
    end

    it 'should set the title if given' do
      title = 'Example'
      attachment = Attachment.from_file(fixture_file_upload('kittens.jpg'), title)
      attachment.title.should == title
    end

    it 'should detect the file extension' do
      attachment = Attachment.from_file(fixture_file_upload('kittens.jpg'))
      attachment.ext.should == '.jpg'
    end
  end

  describe 'ext' do
    it 'should be the extension of the filename' do
      attachment = build(:attachment, filename: 'xyz.pdf')
      attachment.ext.should == '.pdf'
    end

    it 'should be blank if the filename has no extension' do
      attachment = build(:attachment, filename: 'filename-without-extension')
      attachment.ext.should be_blank
    end
  end

  describe 'public_filename' do
    it 'should be a safe combination of title and extension' do
      attachment = build(:attachment, title: 'My Nice Document', filename: 'xyz.pdf')
      attachment.public_filename.should == 'my-nice-document.pdf'
    end

    it 'should be a safe version of the title if it has a file extension' do
      attachment = build(:attachment, title: 'Some Text.txt', filename: 'xyz.doc')
      attachment.public_filename.should == 'some-text.txt'
    end
  end

  describe 'absolute_path' do
    it 'should be the absolute path to the stored file' do
      filename = 'xyz.doc'
      attachment = build(:attachment, filename: filename)
      attachment.absolute_path.should == @store.join(filename)
    end
  end

  describe 'after_destroy' do
    it 'should unlink the file after destroying the record' do
      attachment = Attachment.from_file(fixture_file_upload('kittens.jpg'))
      attachment.absolute_path.should be_file
      attachment.destroy
      attachment.absolute_path.should be_a(Pathname)
      attachment.absolute_path.should_not be_file
    end
  end
end
