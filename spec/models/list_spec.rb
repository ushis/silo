require 'spec_helper'

describe List do
  describe :validations do
    it 'must have a title' do
      expect(subject).to_not be_valid
      expect(subject.errors[:title]).to_not be_empty
    end

    describe 'public lists cant be set to private' do
      context 'when list is private and updated to be public' do
        it 'should be valid' do
          list = build(:list)
          expect(list).to be_private
          list.private = false
          expect(list).to be_valid
        end
      end

      context 'when list is public and updated to be private' do
        it 'should not be valid' do
          list = create(:list, :public)
          list.private = true
          expect(list).to_not be_valid
          expect(list.errors[:private]).to_not be_empty
        end
      end
    end
  end

  describe :associations do
    it { should have_many(:list_items).dependent(:destroy) }
    it { should have_many(:current_users) }
    it { should have_many(:experts).through(:list_items) }
    it { should have_many(:partners).through(:list_items) }

    it { should have_one(:comment).dependent(:destroy) }

    it { should belong_to(:user) }
  end

  describe :new_for_user do
    before(:all) { @user = create(:user) }
    after(:all) { @user.destroy }

    def params
      { title: 'Hello' }
    end

    it 'should be a new list' do
      list = List.new_for_user(params, @user)
      expect(list).to be_a(List)
      expect(list).to be_new_record
    end

    it 'should set the owner to @user' do
      list = List.new_for_user(params, @user)
      expect(list.user).to eq(@user)
    end

    it 'should set the current list of the user after save' do
      list = List.new_for_user(params, @user)
      list.save
      expect(@user.reload.current_list).to eq(list)
    end
  end

  describe :find_for_user do
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

      copy.list_items.should have(4).items
      copy.list_items.should be_all(&:new_record?)
      copy.list_items.should be_all { |item| ! item.note.nil? }
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
      a.list_items.should have(nums[:b]).items

      b.list_items.should have(nums[:b]).items
      b.list_items.should_not be_any(&:changed?)

      a.concat(c)
      a.list_items.should have(nums[:b] + nums[:c]).items
      a.list_items.should be_all { |item| item.note.nil? }
    end
  end

  describe :to_s do
    it 'should be the title' do
      expect(subject.to_s).to eq('')
      subject.title = 'Example'
      expect(subject.to_s).to eq('Example')
    end
  end
end
