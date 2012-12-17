require 'spec_helper'

describe Cv do
  include AttachmentSpecHelper

  context 'validations' do
    it 'must have a cv' do
      cv = Cv.new
      cv.should_not be_valid
      cv.errors[:cv].should_not be_empty
    end
  end

  context 'associations' do
    it { should have_one(:attachment).dependent(:destroy) }

    it { should belong_to(:language) }
    it { should belong_to(:expert) }
  end

  context 'delegations' do
    [:created_at, :absolute_path, :ext].each do |method|
      it { should delegate_method(method).to(:attachment) }
    end
  end

  describe 'from_file' do
    it 'should store the file' do
      cv = nil
      language = build(:language)

      expect {
        cv = Cv.from_file(fixture_file_upload('lorem-ipsum.txt'), build(:language))
      }.to change { count_files(Attachment::STORE) }.by(1)

      cv.should be_a(Cv)
      cv.absolute_path.should be_a(Pathname)
      cv.absolute_path.should be_file
    end

    it 'should load the files content into the cv attribute' do
      file = fixture_file_upload('lorem-ipsum.txt')
      cv = Cv.from_file(file, build(:language))
      file.rewind
      cv.cv.strip.should == file.read.strip
    end

    it 'should load pdf files as well' do
      cv = Cv.from_file(fixture_file_upload('acme.pdf'), build(:language))
      cv.cv.strip.should == 'ACME Inc. - We do it right.'
    end

    it 'should have a blank cv attribute for empty files' do
      cv = Cv.from_file(fixture_file_upload('empty'), build(:language))
      cv.cv.should be_blank
    end

    it 'should have a blank cv attribute for files with no textual content' do
      cv = Cv.from_file(fixture_file_upload('kittens.jpg'), build(:language))
      cv.cv.should be_blank
    end
  end

  describe 'public_filename' do
    it 'should be combination of "cv", experts full_name, language and ext' do
      expert = build(:expert, prename: 'John', name: 'Doe')
      cv = build(:cv)
      cv.language = build(:language, language: :de)
      cv.attachment = build(:attachment, filename: 'example.pdf')
      cv.public_filename.should == 'cv-john-doe-de.pdf'
    end
  end
end
