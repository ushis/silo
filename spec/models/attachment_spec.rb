require 'spec_helper'

describe Attachment do
  include AttachmentSpecHelper

  describe :validations do
    [:filename, :original_filename].each do |attr|
      it { should validate_presence_of(attr) }
    end

    it { should validate_uniqueness_of(:filename) }
  end

  describe :associations do
    it { should belong_to(:attachable) }
  end

  describe :after_destroy do
    subject { Attachment.create!(file: fixture_file_upload('kittens.jpg')) }

    it 'should unlink the file' do
      expect(subject.absolute_path).to be_file
      expect { subject.destroy }.to change { count_files(Attachment::STORE) }.by(-1)
      expect(subject.absolute_path).to_not be_exist
    end
  end

  describe :DIRNAME do
    subject { Attachment::DIRNAME }

    it 'should be the dirname for the attachment store defined in the config' do
      expect(subject).to eq(@store.basename.to_s)
    end
  end

  describe :STORE do
    subject { Attachment::STORE }

    it 'should be the absolute path to the attachment store' do
      expect(subject).to eq(@store)
    end
  end

  describe :file= do
    context 'when valid file input' do
      let(:file) { fixture_file_upload('kittens.jpg') }

      it 'should store the file' do
        expect { subject.file = file }.to change { count_files(Attachment::STORE) }.by(1)
        expect(FileUtils.identical?(fixture_file_path('kittens.jpg'), subject.absolute_path)).to be_true
      end

      it 'should be valid' do
        subject.file = file
        expect(subject).to be_valid
      end

      it 'should detect the file extension' do
        subject.file = file
        expect(subject.ext).to eq('.jpg')
      end
    end

    context 'when invalid input file' do
      let(:file) { 'kittens.jpg' }

      it 'should raise a TypeError' do
        expect { subject.file = file }.to raise_error(TypeError)
      end
    end
  end

  describe :set_title do
    subject { build(:attachment, title: title, original_filename: 'xyz.pdf') }

    context 'when title is present' do
      let(:title) { 'something' }

      it 'should stay the same' do
        expect { subject.set_title }.to_not change { subject.title }
      end
    end

    context 'when title is blank' do
      let(:title) { nil }

      it 'should assign the original filename without extension' do
        subject.set_title
        expect(subject.title).to eq('xyz')
      end
    end
  end

  describe :ext do
    subject { build(:attachment, original_filename: original_filename).ext }

    context 'when original_filename has an extension' do
      let(:original_filename) { 'xyz.pdf' }

      it 'should be the extension of the original filename' do
        expect(subject).to eq('.pdf')
      end
    end

    context 'when original filename has no extension' do
      let(:original_filename) { 'some_file' }

      it 'should be blank' do
        expect(subject).to be_blank
      end
    end
  end

  describe :public_filename do
    subject { build(:attachment, params).public_filename }

    context 'when title has no extension' do
      let(:params) { { title: 'Sweet Document', original_filename: '123.pdf' } }

      it 'should be a safe combination of title and extension' do
        expect(subject).to eq('sweet-document.pdf')
      end
    end

    context 'when title has a file extension' do
      let(:params) { { title: 'index.html', original_filename: '123.html' } }

      it 'should remove the titles extension before making it safe' do
        expect(subject).to eq('index.html')
      end
    end
  end

  describe :absolute_path do
    subject { build(:attachment, filename: 'xyz.doc').absolute_path }

    it 'should be the absolute path to the stored file' do
      expect(subject).to eq(@store.join('xyz.doc'))
    end
  end
end
