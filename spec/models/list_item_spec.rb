require 'spec_helper'

describe ListItem do
  context 'associations' do
    it { should belong_to(:list) }
    it { should belong_to(:item) }
  end

  describe 'TYPES' do
    it 'should be a hash containing item types' do
      ListItem::TYPES.should == { experts: Expert, partners: Partner }
    end
  end

  describe 'class_for_item_type' do
    it 'should raise an ArgumentError for invalid item types' do
      expect { ListItem.class_for_item_type(:invalid) }.to raise_error(ArgumentError)
    end

    it 'should be the model class for the item type' do
      ListItem.class_for_item_type(:experts).should == Expert
    end
  end

  describe 'by_type' do
    it 'should raise an ArgumentError for invalid item types' do
      expect { ListItem.by_type(:invalid) }.to raise_error(ArgumentError)
    end

    it 'should be a collection of list items of the specified type' do
      list = create(:list_with_items)

      ListItem.by_type(:experts).each do |list_item|
        list_item.item_type.should == 'Expert'
      end
    end
  end

  describe 'collection' do
    it 'should raise an ArgumentError for invalid item types' do
      expect { ListItem.collection(:invalid, [1, 2, 3]) }.to raise_error(ArgumentError)
    end

    it 'should be an empty collection for non existing items' do
      ListItem.collection(:experts, [1, 2, 3]).should be_empty
    end

    it 'should be a collection of fresh list items' do
      partners = (1..3).map { |_| create(:partner) }
      experts = (1..3).map { |_| create(:expert) }

      list_items = ListItem.collection(:experts, experts)

      list_items.each do |list_item|
        list_item.should be_a(ListItem)
        list_item.should be_new_record
      end

      list_items.map(&:item).should =~ experts
    end
  end

  describe 'copy' do
    it 'should be a fresh copy of the list item with an erased note' do
      original = create(:list_item)

      copy = original.copy
      copy.should be_new_record
      copy.note.should be_nil
    end

    it 'should be a fresh copy including the note' do
      original = create(:list_item)

      copy = original.copy(false)
      copy.should be_new_record
      copy.note.should == original.note
    end
  end

  describe 'name' do
    it 'should be string representation of the actual item' do
      list_item = build(:list_item)
      list_item.name.should == list_item.item.to_s
    end
  end

  describe 'to_s' do
    it 'should be the list items name' do
      list_item = build(:list_item)
      list_item.to_s.should == list_item.name
    end
  end
end
