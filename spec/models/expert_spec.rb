require 'spec_helper'

describe Expert do
  include AttachmentSpecHelper

  describe :validations do
    it { should validate_presence_of(:name) }
  end

  describe :associations do
    it { should have_and_belong_to_many(:languages) }

    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:addresses).dependent(:destroy) }
    it { should have_many(:list_items).dependent(:destroy) }
    it { should have_many(:lists).through(:list_items) }
    it { should have_many(:cvs).dependent(:destroy) }

    it { should have_one(:contact).dependent(:destroy) }
    it { should have_one(:comment).dependent(:destroy) }

    it { should belong_to(:user) }
    it { should belong_to(:country) }
  end

  describe :full_name do
    subject { build(:expert, prename: 'John', name: 'Doe').full_name }

    it 'should be a combination of prename and name' do
      expect(subject).to eq('John Doe')
    end
  end

  describe :full_name_with_degree do
    subject do
      build(:expert, prename: 'John', name: 'Doe', degree: degree).full_name_with_degree
    end

    context 'with a degree' do
      let(:degree) { 'Ph.D.' }

      it 'should be a combination of prename, name and degree' do
        expect(subject).to eq('John Doe, Ph.D.')
      end
    end

    context 'without a degree' do
      let(:degree) { nil }

      it 'should be the full name' do
        expect(subject).to eq('John Doe')
      end
    end
  end

  describe :former_collaboration do
    it 'should be false by default' do
      expect(subject.former_collaboration).to be_false
    end
  end

  describe 'human_former_collaboration' do
    subject do
      build(:expert, former_collaboration: value).human_former_collaboration
    end

    context 'when it is false' do
      let(:value) { false }

      it 'should be the translated string for false' do
        expect(subject).to eq(I18n.t('values.boolean.false'))
      end
    end

    context 'when it is true' do
      let(:value) { true }

      it 'should be the translated string for true' do
        expect(subject).to eq(I18n.t('values.boolean.true'))
      end
    end
  end

  describe :human_birthday do
    subject do
      build(:expert, birthday: Date.new)
    end

    it 'should be the short localized date' do
      expect(subject.human_birthday).to eq(I18n.l(subject.birthday, format: :short))
    end

    context 'when argument is :long' do
      it 'should be the long localized date' do
        expect(subject.human_birthday(:long)).to eq(I18n.l(subject.birthday, format: :long))
      end
    end
  end

  describe :age do
    subject { build(:expert, birthday: birthday).age }

    context 'when birthday is nill' do
      let(:birthday) { nil }

      it 'should be nil' do
        expect(subject).to be_nil
      end
    end

    context 'when expert is 24' do
      let(:birthday) { 24.years.ago.utc.to_date }

      it 'should be 24' do
        expect(subject).to eq(24)
      end
    end

    context 'when expert is 23' do
      let(:birthday) { 24.years.ago + 1.day }

      it 'should be 23' do
        expect(subject).to eq(23)
      end
    end
  end

  describe :to_s do
    subject { build(:expert, name: name, prename: prename).to_s }

    let(:name) { 'Walter' }
    let(:prename) { 'Bill' }

    it 'should be a combination of last name, first name' do
      expect(subject).to eq('Walter, Bill')
    end

    context 'without a first name' do
      let(:prename) { nil }

      it 'should be the last name' do
        expect(subject).to eq('Walter')
      end
    end

    context 'without a last name' do
      let(:name) { nil }

      it 'should be the first name' do
        expect(subject).to eq('Bill')
      end
    end

    context 'without any name' do
      let(:name) { nil }
      let(:prename) { nil }

      it 'should be empty' do
        expect(subject).to be_empty
      end
    end
  end
end
