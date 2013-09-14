require 'spec_helper'

describe Project do
  describe :validations do
    it { should ensure_inclusion_of(:carried_proportion).in_range(0..100) }
    it { should ensure_inclusion_of(:status).in_array(
      [:forecast, :interested, :offer, :execution, :stopped, :complete]) }

    describe :start_must_be_earlier_than_end do
      subject { build(:project, start: startDate, end: endDate) }

      context 'when start is earlier than end' do
        let(:startDate) { Date.new(1980, 3, 3) }
        let(:endDate)   { Date.new(2000, 2, 1) }

        it 'should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'when start is nil' do
        let(:startDate) { nil }
        let(:endDate)   { Date.new(2000, 2, 1) }

        it 'should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'when end is nil' do
        let(:startDate) { Date.new(1980, 3, 3) }
        let(:endDate)   { nil }

        it 'should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'when start is later than end' do
        let(:startDate) { Date.new(2000, 2, 1) }
        let(:endDate)   { Date.new(1980, 3, 3) }

        it 'should not be valid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:start]).to_not be_empty
          expect(subject.errors[:end]).to_not be_empty
        end
      end
    end
  end

  describe :associations do
    it { should have_and_belong_to_many(:partners) }

    it { should have_many(:infos).dependent(:destroy) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:list_items).dependent(:destroy) }
    it { should have_many(:lists).through(:list_items) }

    it { should belong_to(:user) }
    it { should belong_to(:country) }
  end

  describe :first_period_year do
    subject { Project.first_period_year }

    it 'should be 1970' do
      expect(subject).to eq(1970)
    end
  end

  describe :last_period_year do
    subject { Project.last_period_year }

    it 'should be 50 years after today' do
      expect(subject).to eq(Time.now.year + 50)
    end
  end

  describe :max_period do
    subject { Project.max_period }

    it 'should be range from the first possible year to the last' do
      expect(subject).to eq(Project.first_period_year..Project.last_period_year)
    end
  end

  describe :human_start do
    subject { build(:project, start: date).human_start(:short) }

    context 'when the start date is nil' do
      let(:date) { nil }

      it 'should be nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the start date is a valid date' do
      let(:date) { Date.new(2001, 1, 13) }

      it 'should be the human readable start date' do
        expect(subject).to eq('January 13, 2001')
      end
    end
  end

  describe :human_end do
    subject { build(:project, end: date).human_end(:short) }

    context 'when the start date is nil' do
      let(:date) { nil }

      it 'should be nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the start date is a valid date' do
      let(:date) { Date.new(2001, 1, 13) }

      it 'should be the human readable end date' do
        expect(subject).to eq('January 13, 2001')
      end
    end
  end

  describe :info? do
    context 'without any infos' do
      subject { create(:project) }

      it 'should be false' do
        expect(subject.info?).to be_false
      end
    end

    context 'with infos' do
      subject { create(:project, :with_infos) }

      it 'should be true' do
        expect(subject.info?).to be_true
      end
    end
  end

  describe :info do
    subject { create(:project, :with_infos) }

    it 'should be the first info' do
      expect(subject.info).to eq(subject.infos.first)
    end
  end

  describe :info_by_language do
    context 'without the specified info' do
      subject { create(:project) }

      it 'should not be persisted' do
        expect(subject.info_by_language(:de)).to_not be_persisted
      end

      it 'have the specified language' do
        expect(subject.info_by_language(:de).language).to eq('de')
      end

      it 'should be associated with the project' do
        expect(subject.info_by_language(:de).project).to eq(subject)
      end
    end

    context 'with the specified info' do
      subject { create(:project, :with_infos) }

      it 'should be the correct info' do
        expect(subject.info_by_language(:en)).to eq(subject.infos.find_by_language(:en))
      end
    end
  end

  describe :info_by_language! do
    context 'without the specified info' do
      subject { create(:project) }

      it 'should throw an exception' do
        expect { subject.info_by_language!(:es) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with the specified info' do
      subject { create(:project, :with_infos) }

      it 'should be the correct info' do
        expect(subject.info_by_language!(:fr)).to eq(subject.infos.find_by_language(:fr))
      end
    end
  end

  describe :potential_experts do
    before(:all) { @members = (1..3).map { create(:project_member) } }

    after(:all) { [Expert, Project, User].each { |m| m.destroy_all } }

    subject { create(:project, members: members).potential_experts }

    context 'when the project has no members' do
      let(:members) { [] }

      it 'should be a collection of all members' do
        expect(subject).to match_array(@members.map(&:expert))
      end
    end

    context 'when the project has all members' do
      let(:members) { @members }

      it 'should find nothing' do
        expect(subject).to eq([])
      end
    end

    context 'when project has one member' do
      let(:members) { [@members[0]] }

      it 'should find the other partners' do
          expect(subject).to match_array(@members[1..2].map(&:expert))
      end
    end
  end

  describe :potential_partners do
    before(:all) { @partners = (1..3).map { create(:partner) } }

    after(:all) { [Partner, User].each { |m| m.destroy_all } }

    subject { create(:project, partners: partners).potential_partners }

    context 'when the project has no partners' do
      let(:partners) { [] }

      it 'should be a collection of all partners' do
        expect(subject).to match_array(@partners)
      end
    end

    context 'when the project has all partners' do
      let(:partners) { @partners }

      it 'should find nothing' do
        expect(subject).to eq([])
      end
    end

    context 'when project has one partner' do
      let(:partners) { [@partners[0]] }

      it 'should find the other partners' do
          expect(subject).to match_array(@partners[1..2])
      end
    end
  end

  describe :add_partner do
    subject { create(:project, :with_partners) }

    context 'when adding a new partner' do
      it 'should be the new collection of partners' do
        expect(subject.add_partner(build(:partner))).to match_array(subject.partners)
      end
    end

    context 'when adding an already added partner' do
      it 'should be false' do
        expect(subject.add_partner(subject.partners.first)).to be_false
      end
    end
  end

  describe :update_title do
    subject { create(:project, :with_infos) }

    before { subject.update_attribute(:title, 'Something') }

    it 'should be true' do
      expect(subject.update_title).to be_true
    end

    it 'should change the title from "Something" to the title of the first info' do
      expect {
        subject.update_title
      }.to change {
        subject.title
      }.from('Something').to(subject.info.title)
    end
  end

  describe :to_s do
    subject { create(:project, title: 'Something').to_s }

    it 'should be title' do
      expect(subject).to eq('Something')
    end
  end
end
