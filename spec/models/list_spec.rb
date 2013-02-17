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
    before do
      create(:list, private: true)
      create(:list, private: false)
      create(:list, private: true, user: user)
    end

    let(:user) { create(:user) }

    subject { List.accessible_for(user) }

    it { should have(2).items }

    it 'should have lists which are accesible by the user' do
      expect(subject).to be_all { |list| list.accessible_for?(user) }
    end
  end

  describe :accessible_for? do
    subject { list.accessible_for?(user) }

    let(:user) { build(:user) }

    context 'when list is private and user is not the owner' do
      let(:list) { build(:list, private: true) }

      it { should be_false }
    end

    context 'when list is public' do
      let(:list) { build(:list, private: false) }

      it { should be_true }
    end

    context 'when user is the owner' do
      let(:list) { build(:list, private: true, user: user) }

      it { should be_true }
    end
  end

  describe :add do
    context 'when item type is invalid' do
      subject { build(:list) }

      it 'should raise an ArgumentError' do
        expect { subject.add(:invalid, [1, 2]) }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      subject { create(:list) }

      let(:experts) { (1..4).map { |_| create(:expert) } }

      it 'should a add the items' do
        expect {
          subject.add(:experts, experts)
        }.to change {
          subject.list_items.map(&:item)
        }.from([]).to(experts)
      end

      context 'when adding not existing items' do
        let(:experts) { [0, create(:expert), 1, -12] }

        it 'should ignore them' do
          expect {
            subject.add(:experts, experts)
          }.to change {
            subject.list_items.map(&:item)
          }.from([]).to([experts[1]])
        end
      end
    end
  end

  describe :remove do
    context 'when item type is invalid' do
      subject { build(:list) }

      it 'should raise an ArgumentError' do
        expect { subject.remove(:invalid, [1, 2]) }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      subject { create(:list) }

      let(:partners) { (1..4).map { |_| create(:partner) } }

      before { subject.add(:partners, partners) }

      it 'remove the items' do
        expect {
          subject.remove(:partners, partners[0..1])
        }.to change {
          subject.list_items(true).map(&:item)
        }.from(partners).to(partners[2..3])
      end

      context 'when removing none existing items' do
        it 'should ignore them' do
          expect {
            subject.remove(:partners, [1, -12, 0, partners.last])
          }.to change {
            subject.list_items(true).map(&:item)
          }.from(partners).to(partners[0..-2])
        end
      end
    end
  end

  describe :copy do
    subject { create(:list_with_items) }

    it 'should be be the same as the original' do
      expect(subject.copy).to_not eq(subject)
    end

    it 'should not change the original list' do
      expect { subject.copy }.to_not change { subject.changed? }
    end

    it 'should be a new record' do
      expect(subject.copy).to be_new_record
    end

    it 'should have excat same number of items as the original list' do
      expect(subject.copy.list_items.length).to eq(subject.list_items.count)
    end

    it 'should have fresh copies of the list items' do
      expect(subject.copy.list_items).to be_all(&:new_record?)
    end

    it 'should have list items with copied notes' do
      expect(subject.copy.list_items).to be_all { |item| item.note.present? }
    end

    context 'with params' do
      let(:title) { 'Yet Another List Title' }

      it 'should merge the params' do
        expect(subject.copy(title: title).title).to eq(title)
      end
    end

    context 'with evil params' do
      it 'should raise an error' do
        expect { subject.copy(user_id: 12) }.to raise_error
      end
    end
  end

  describe :concat do
    subject { create(:list_with_3_items) }

    before do
      @other = create(:list_with_items)
    end

    it 'should not change to other list' do
      expect { subject.concat(@other) }.to_not change { @other.changed? }
    end

    it 'should not change the list items of the other list' do
      expect {
        subject.concat(@other)
      }.to_not change {
        @other.list_items.any?(&:changed?)
      }
    end

    it 'should include the items of the other list' do
      expect {
        subject.concat(@other)
      }.to change {
        subject.list_items.length
      }.from(3).to(3 + @other.list_items.count)
    end

    it 'should have fresh items' do
      expect {
        subject.concat(@other)
      }.to_not change { subject.list_items(true) & @other.list_items }
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
