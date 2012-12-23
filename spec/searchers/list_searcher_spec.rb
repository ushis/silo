require 'spec_helper'

describe ListSearcher do
  subject { ListSearcher.new(conditions).search.all }

  before(:all) do
    @private_jane = create(:list, title: 'Jane Doe')
    @private_adam = create(:list, title: 'Adam Frost')
    @public_peter = create(:list, title: 'Peter Griffin', private: false)
  end

  after(:all) do
    [@private_adam, @private_jane, @public_peter].each do |list|
      list.user.destroy
      list.destroy
    end
  end

  describe :search do
    context 'when searching for private lists' do
      let(:conditions) { { private: true } }

      it 'should be private lists only' do
        expect(subject).to match_array([@private_adam, @private_jane])
      end
    end

    context 'when searching for public lists' do
      ['0', 0, false].each do |value|
        let(:conditions) { { private: value } }

        it 'should be public lists only' do
          expect(subject).to eq([@public_peter])
        end
      end
    end

    context 'when searching for title' do
      let(:conditions) { { title: 'ane' } }

      it 'should be lists found by partial match' do
        expect(subject).to eq([@private_jane])
      end
    end

    context 'when excluding lists' do
      let(:conditions) { { exclude: [@private_jane, @public_peter] } }

      it 'should be an without the excluded lists' do
        expect(subject).to match_array([@private_adam])
      end
    end

    context 'when searching for title "a" and excluding adam' do
      let(:conditions) { { title: 'a', exclude: @private_adam } }

      it 'should be jane only' do
        expect(subject).to eq([@private_jane])
      end
    end

    context 'when search for private lists with title "doe"' do
      let(:conditions) { { title: 'doe', private: true } }

      it 'should be jane only' do
        expect(subject).to eq([@private_jane])
      end
    end

    context 'when searching for public lists and title "ad"' do
      let(:conditions) { { title: 'ad', private: false } }

      it 'should be empty' do
        expect(subject).to be_empty
      end
    end
  end
end
