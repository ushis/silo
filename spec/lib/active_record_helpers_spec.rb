require 'spec_helper'

describe ActiveRecordHelpers do
  before(:all) do
    build_model :active_record_helpers_dummy do
      belongs_to :category
      has_one :author
      has_many :comments
      has_and_belongs_to_many :tags
    end
  end

  describe :filter_associations do
    subject { ActiveRecordHelpersDummy.filter_associations(fields) }

    context 'with a bunch of fields' do
      let(:fields) { [:category, :title, :body, :tags] }

      it 'should filter the associations' do
        expect(subject).to match_array([:category, :tags])
      end
    end

    context 'with stringified fields' do
      let(:fields) { %w(author body comments tags) }

      it 'should filter the associations' do
        expect(subject).to match_array([:author, :comments, :tags])
      end
    end
  end

  describe :association? do
    subject { ActiveRecordHelpersDummy.association?(value) }

    context 'when value is no association' do
      let(:value) { :title }

      it { should be_false }
    end

    context 'when value is a association' do
      let(:value) { :tags }

      it { should be_true }
    end

    context 'when value is a stringified association' do
      let(:value) { 'comments' }

      it { should be_true}
    end
  end

  describe :belongs_to? do
    subject { ActiveRecordHelpersDummy.belongs_to?(value) }

    context 'when value is no association' do
      let(:value) { :title }

      it { should be_false }
    end

    context 'when value is no belongs_to association' do
      let(:value) { :author }

      it { should be_false }
    end

    context 'when value is a belongs_to association' do
      let(:value) { :category }

      it { should be_true }
    end

    context 'when value is a stringified belongs_to association' do
      let(:value) { 'category' }

      it { should be_true }
    end
  end

  describe :has_one? do
    subject { ActiveRecordHelpersDummy.has_one?(value) }

    context 'when value is no association' do
      let(:value) { :title }

      it { should be_false }
    end

    context 'when value is no has_one association' do
      let(:value) { :category }

      it { should be_false }
    end

    context 'when value is a has_one association' do
      let(:value) { :author }

      it { should be_true }
    end

    context 'when value is a stringified has_one association' do
      let(:value) { 'author' }

      it { should be_true }
    end
  end

  describe :has_many? do
    subject { ActiveRecordHelpersDummy.has_many?(value) }

    context 'when value is no association' do
      let(:value) { :title }

      it { should be_false }
    end

    context 'when value is no has_many association' do
      let(:value) { :tags }

      it { should be_false }
    end

    context 'when value is a has_many association' do
      let(:value) { :comments }

      it { should be_true }
    end

    context 'when value is a stringified has_many association' do
      let(:value) { 'comments' }

      it { should be_true }
    end
  end

  describe :has_and_belongs_to_many? do
    subject { ActiveRecordHelpersDummy.has_and_belongs_to_many?(value) }

    context 'when value is no association' do
      let(:value) { :title }

      it { should be_false }
    end

    context 'when value is no has_and_belongs_to_many association' do
      let(:value) { :comments }

      it { should be_false }
    end

    context 'when value is a has_and_belongs_to_many association' do
      let(:value) { :tags }

      it { should be_true }
    end

    context 'when value is a stringified has_and_belongs_to_many association' do
      let(:value) { 'tags' }

      it { should be_true }
    end
  end
end
