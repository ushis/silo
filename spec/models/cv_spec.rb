require 'spec_helper'

describe Cv do
  include AttachmentSpecHelper

  describe :validations do
    it { should validate_presence_of(:cv) }
  end

  describe :associations do
    it { should have_one(:attachment).dependent(:destroy) }

    it { should belong_to(:language) }
    it { should belong_to(:expert) }
  end

  describe :delegations do
    [:created_at, :absolute_path, :ext].each do |method|
      it { should delegate_method(method).to(:attachment) }
    end
  end

  describe :file= do
    context 'when argument is a valid file' do
      let(:file) { fixture_file_upload('lorem-ipsum.txt') }

      it 'should store the file' do
        expect { subject.file = file }.to change { count_files(Attachment::STORE) }.by(1)
        expect(subject.absolute_path).to be_file
      end

      it 'should load the files content into the cv attribute' do
        expect(subject.cv).to be_nil
        subject.file = file
        file.rewind
        expect(subject.cv.strip).to eq(file.read.strip)
      end
    end

    ['acme.pdf', 'acme.doc'].each do |filename|
      context "when file is #{filename}" do
        let(:file) { fixture_file_upload(filename) }

        it 'should work too' do
          expect(subject.cv).to be_nil
          subject.file = file
          expect(subject.cv.strip).to eq('ACME Inc. - We do it right.')
        end
      end
    end

    ['empty', 'kittens.jpg'].each do |filename|
      context "when file is #{filename}" do
        let(:file) { fixture_file_upload(filename) }

        it 'should have a blank cv attribute' do
          expect(subject.cv).to be_nil
          subject.file = file
          expect(subject.cv).to be_blank
        end
      end
    end

    context 'when argument is not a file' do
      let(:file) { 'kittens.jpg' }

      it 'should raise a TypeError' do
        expect { subject.file = file }.to raise_error(TypeError)
      end
    end
  end

  describe :public_filename do
    subject do
      expert = build(:expert, prename: 'John', name: 'Doe')
      language = build(:language, language: :de)
      attachment = build(:attachment, original_filename: 'example.pdf')
      build(:cv, expert: expert, language: language, attachment: attachment).public_filename
    end

    it 'should be combination of "cv", experts full_name, language and ext' do
      expect(subject).to eq('cv-john-doe-de.pdf')
    end
  end
end
