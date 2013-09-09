require 'spec_helper'

describe ListItem do
  describe :associations do
    it { should belong_to(:list) }
    it { should belong_to(:item) }
  end

  describe :TYPES do
    subject { ListItem::TYPES }

    it 'should be a hash containing item types' do
      expect(subject).to eq({ experts: Expert, partners: Partner, projects: Project })
    end
  end

  describe :class_for_item_type do
    context 'invalid item type' do
      it 'should raise an ArgumentError' do
        expect {
          ListItem.class_for_item_type(:invalid)
        }.to raise_error(ArgumentError)
      end
    end

    context 'valid item type' do
      subject { ListItem.class_for_item_type(:experts) }

      it 'should be the model class' do
        expect(subject).to eq(Expert)
      end
    end
  end

  describe :by_type do
    context 'with invalid item type' do
      it 'should raise an ArgumentError' do
        expect { ListItem.by_type(:invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'with valid item type' do
      before do
        3.times { create(:list_item, item: build(:expert)) }
        3.times { create(:list_item, item: build(:partner)) }
      end

      subject { ListItem.by_type(:experts) }

      it 'should have all experts' do
        expect(subject).to have(3).items
      end

      it 'should be a collection of list items of the specified type' do
        expect(subject).to be_all { |item| item.item_type == 'Expert' }
      end
    end

    context 'with the order option' do
      before do
        3.times { create(:list_item, item: build(:expert)) }
      end

      subject { ListItem.by_type(:experts, order: true) }

      it 'should include the ordered items' do
        expect(subject.map(&:item)).to eq(Expert.order(Expert::DEFAULT_ORDER))
      end
    end
  end

  describe :collection do
    context 'invalid item type' do
      it 'should raise an ArgumentError' do
        expect {
          ListItem.collection(:invalid, [1, 2, 3])
        }.to raise_error(ArgumentError)
      end
    end

    context 'not exsiting ids' do
      subject { ListItem.collection(:experts, [2, 3, 4]) }

      it 'should be an empty' do
        expect(subject).to be_empty
      end
    end

    context 'when everything is fine' do
      before do
        3.times { create(:partner) }
        @experts = (1..3).map { |_| create(:expert) }
      end

      subject { ListItem.collection(:experts, @experts.map(&:id)) }

      it 'should be not be empty' do
        expect(subject).to_not be_empty
      end

      it 'should be a collection of list items' do
        expect(subject).to be_all { |item| item.is_a?(ListItem) }
      end

      it 'should be a collection of new records' do
        expect(subject).to be_all { |item| item.new_record? }
      end

      it 'should contain all created items' do
        expect(subject.map(&:item)).to match_array(@experts)
      end
    end
  end

  describe :copy do
    before { @item = create(:list_item) }

    subject { @item.copy }

    it 'should be a new record' do
      expect(subject).to be_new_record
    end

    it 'should have the same note as the original' do
      expect(subject.note).to eq(@item.note)
    end

    context 'with params' do
      subject { @item.copy(note: 'Some other note.') }

      it 'should merge the params' do
        expect(subject.note).to eq('Some other note.')
      end
    end

    context 'with evil params' do
      it 'should raise an error' do
        expect { @item.copy(item_id: 12) }.to raise_error
      end
    end
  end

  describe :name do
    subject { build(:list_item) }

    it 'should be string representation of the actual item' do
      expect(subject.name).to eq(subject.item.to_s)
    end
  end

  describe :to_s do
    subject { build(:list_item) }

    it 'should be the list items name' do
      expect(subject.to_s).to eq(subject.name)
    end
  end
end
