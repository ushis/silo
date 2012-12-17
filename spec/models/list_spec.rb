require 'spec_helper'

describe List do
  context 'validations' do
    it 'must have a title' do
      l = List.new
      l.should_not be_valid
      l.errors[:title].should_not be_empty
    end
  end

  context 'associations' do
    it { should have_many(:list_items).dependent(:destroy) }
    it { should have_many(:current_users) }
    it { should have_many(:experts).through(:list_items) }
    it { should have_many(:partners).through(:list_items) }

    it { should have_one(:comment).dependent(:destroy) }

    it { should belong_to(:user) }
  end

  describe 'find_for_user' do
    it 'should a find the users list' do
      user = create(:user)
      list = create(:list, user: user)

      List.find_for_user(list.id, user).should == list
    end

    it 'should raise a not found error' do
      user = create(:user)

      expect { List.find_for_user(1, user) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should raise an unauthorized error' do
      stranger = create(:user)
      list = create(:list)

      expect { List.find_for_user(list.id, stranger) }.to raise_error(UnauthorizedError)
    end
  end

  describe 'accessible_for' do
    it 'should find lists accessible for a specific user' do
      user = create(:user)
      a = create(:list)
      b = create(:list, :public)
      c = create(:list, user: user)

      List.all.should =~ [a, b, c]
      List.accessible_for(user) =~ [b, c]
    end
  end

  describe 'search' do
    it 'should find lists by partial title' do
      a = create(:list, title: 'Project A')
      b = create(:list, title: 'Project B')
      c = create(:list, title: 'Hello World')

      List.all.should =~ [a, b, c]
      List.search(title: 'oject').should =~ [a, b]
    end

    it 'should find public lists only' do
      a = create(:list, :public)
      b = create(:list, :public)
      c = create(:list)
      d = create(:list)

      List.all.should =~ [a, b, c, d]
      List.search(private: '1').should =~ [c, d]
    end

    it 'should not find excluded lists' do
      a = create(:list)
      b = create(:list)
      c = create(:list)

      List.all.should =~ [a, b, c]
      List.search(exclude: [a, c]).should =~ [b]
    end
  end

  describe 'accessible_for?' do
    it 'should be false for strangers' do
      user = build(:user)
      list = build(:list)

      list.accessible_for?(user).should be_false
    end

    it 'should be true for public lists' do
      user = build(:user)
      list = build(:list, :public)

      list.accessible_for?(user).should be_true
    end

    it 'should be true for list owners' do
      user = build(:user)
      list = build(:list, user: user)

      list.accessible_for?(user).should be_true
    end
  end

  describe 'add' do
    it 'should raise an ArgumentError for invalid item types' do
      l = build(:list)
      expect { l.add(:invalid, [1, 2, 3]) }.to raise_error(ArgumentError)
    end

    it 'should add experts to the list' do
      list = create(:list)
      experts = (1..4).map { |_| create(:expert) }
      list.add(:experts, experts)
      list.experts.should =~ experts
    end
  end

  describe 'remove' do
    it 'should raise an ArgumentError for invalid item types' do
      l = build(:list)
      expect { l.remove(:invalid, [1, 2, 3]) }.to raise_error(ArgumentError)
    end

    it 'should remove partners from the list' do
      list = create(:list)
      partners = (1..4).map { |_| create(:partner) }
      list.add(:partners, partners)
      list.partners.should =~ partners
      list.remove(:partners, partners[0..1])
      list.partners(true).should =~ partners[2..3]
    end
  end

  describe 'copy' do
    it 'should be a copy of the list with copies of the list items' do
      list = create(:list)
      4.times { list.list_items << build(:list_item) }

      copy = list.copy

      list.should_not be_changed
      copy.should be_new_record

      copy.list_items.length.should == 4
      copy.list_items.all?(&:new_record?).should be_true
      copy.list_items.all? { |item| ! item.note.nil? }.should be_true
    end
  end

  describe 'concat' do
    it 'should concatenate two lists and erase the list item notes' do
      a = create(:list)
      b = create(:list_with_items)
      c = create(:list_with_items)

      nums = { b: b.list_items.length, c: c.list_items.length }
      nums.values.reduce(:+).should > 0

      a.concat(b)
      a.list_items.length.should == nums[:b]

      b.list_items.length.should == nums[:b]
      b.list_items.any?(&:changed?).should be_false

      a.concat(c)
      a.list_items.length.should == nums[:b] + nums[:c]
      a.list_items.all? { |item| item.note.nil? }.should be_true
    end
  end
end
