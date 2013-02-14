require 'spec_helper'

describe List do
  describe :validations do
    it { should validate_presence_of(:title) }

    describe 'public lists cant be set to private' do
      subject { create(:list, private: privacy) }

      context 'when list is private and updated to be public' do
        let(:privacy) { true }

        before { subject.private = false }

        it 'should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'when list is public and updated to be private' do
        let(:privacy) { false }

        before { subject.private = true }

        it 'should not be valid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:private]).to_not be_empty
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

  describe :accessible_for do
    it 'should find lists accessible for a specific user' do
      user = create(:user)
      a = create(:list)
      b = create(:list, :public)
      c = create(:list, user: user)

      expect(List.all).to match_array([a, b, c])
      expect(List.accessible_for(user)).to match_array([b, c])
      expect(user.accessible_lists).to match_array([b, c])
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

  describe :copy do
    before do
      @list = create(:list)
      3.times { @list.list_items << build(:list_item) }
    end

    subject { @list.copy }

    it 'should not change the original list' do
      expect(@list).to_not be_changed
    end

    it 'should be a new record' do
      expect(subject).to be_new_record
    end

    it 'should have excat same number of items as the original list' do
      expect(subject.list_items.count).to eq(@list.list_items.count)
    end

    it 'should have fresh copies of the list items' do
      expect(subject.list_items).to be_all(&:new_record?)
    end

    it 'should have list items with copied notes' do
      expect(subject.list_items).to be_all { |item| ! item.note.blank? }
    end

    context 'with params' do
      subject { @list.copy(title: 'Yet Another List Title') }

      it 'should merge the params' do
        expect(subject.title).to eq('Yet Another List Title')
      end
    end

    context 'with evil params' do
      it 'should raise an error' do
        expect { @list.copy(user_id: 12) }.to raise_error
      end
    end
  end

  describe :concat do
    subject { create(:list_with_items) }

    before do
      @count = subject.list_items.length
      @other = create(:list_with_items)
      subject.concat(@other)
    end

    it 'should not change to other list' do
      expect(@other).to_not be_changed
    end

    it 'should not change the list items of the other list' do
      expect(@other.list_items).to_not be_any(&:changed?)
    end

    it 'should include the items of the other list' do
      expect(subject.list_items).to have(@count + @other.list_items.length).items
    end

    it 'should have fresh items' do
      expect(subject.list_items).to_not be_any { |item|
        @other.list_items.include?(item)
      }
    end
  end

  describe :public? do
    context 'when list is private' do
      subject { build(:list, private: true) }

      it 'should be false' do
        expect(subject.public?).to be_false
      end
    end

    context 'when list is public' do
      subject { build(:list, private: false) }

      it 'should be true' do
        expect(subject.public?).to be_true
      end
    end
  end

  describe :to_s do
    subject { build(:list, title: 'Example List') }

    it 'should be the title' do
      expect(subject.to_s).to eq('Example List')
    end
  end
end
