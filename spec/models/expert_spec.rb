require 'spec_helper'

describe Expert do
  include AttachmentSpecHelper

  describe :validations do
    it 'must have a name' do
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to_not be_empty
    end
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

  describe :add_cv_from_upload do
    before(:all) do
      @expert = create(:expert)
      @lang = create(:language)
    end

    after(:all) do
      @expert.user.destroy
      @expert.destroy
      @lang.destroy
    end

    context 'when data valid' do
      def params
        { file: fixture_file_upload('lorem-ipsum.txt'), language_id: @lang }
      end

      it 'should be truthy' do
        expect(@expert.add_cv_from_upload(params)).to be_true
      end

      it 'should store the cv' do
        expect {
          @expert.add_cv_from_upload(params)
        }.to change { count_files(Attachment::STORE) }.by(1)
      end

      it 'should add a cv' do
        expect {
          @expert.add_cv_from_upload(params)
        }.to change { @expert.cvs(true).count }.by(1)
      end
    end

    [
      { file: 'empty' },
      { file: 'kittens.jpg' },
      { language_id: nil },
      { language_id: 'invalid' }
    ].each do |params|
      context "when #{params.keys.first} is #{params.values.first.inspect}" do
        before do
          @params = { file: fixture_file_upload(params[:file] || 'lorem-ipsum.txt') }
          @params[:language_id] = params.key?(:language_id) ? params[:language_id] : @lang
        end

        it 'should be false' do
          expect(@expert.add_cv_from_upload(@params)).to be_false
        end

        it 'should not store the cv' do
          expect {
            @expert.add_cv_from_upload(@params)
          }.to_not change { count_files(Attachment::STORE) }
        end

        it 'should not add the cv' do
          expect {
            @expert.add_cv_from_upload(@params)
          }.to_not change { @expert.cvs(true).count }
        end
      end
    end
  end

  describe 'full_name' do
    it 'should be a combination of prename and name' do
      e = build(:expert, prename: 'John', name: 'Doe')
      e.full_name.should == 'John Doe'
    end
  end

  describe 'full_name_with_degree' do
    it 'should be a combination of prename, name and degree' do
      e = build(:expert, prename: 'John', name: 'Doe', degree: 'Ph.D.')
      e.full_name_with_degree.should == 'John Doe, Ph.D.'
    end

    it 'should be full_name if degree is blank' do
      e = build(:expert, prename: 'John', name: 'Doe')
      e.full_name_with_degree.should == e.full_name
    end
  end

  describe 'former_collaboration' do
    it 'should be false by default' do
      Expert.new.former_collaboration.should == false
    end
  end

  describe 'human_former_collaboration' do
    it 'should be the translated string for false' do
      e = build(:expert, former_collaboration: false)
      e.human_former_collaboration.should == I18n.t('values.boolean.false')
    end

    it 'should be the translated string for true' do
      e = build(:expert, former_collaboration: true)
      e.human_former_collaboration.should == I18n.t('values.boolean.true')
    end
  end

  describe 'human_birthday' do
    it 'should be the short localized string for the date of birth' do
      date = Date.new
      e = build(:expert, birthday: date)
      e.human_birthday.should == I18n.l(date, format: :short)
    end

    it 'should be the long localized string for the date of birth' do
      date = Date.new
      e = build(:expert, birthday: date)
      e.human_birthday(:long).should == I18n.l(date, format: :long)
    end
  end

  describe 'age' do
    it 'should be nil for unset birthdays' do
      Expert.new.age.should be_nil
    end

    it 'should be the age in years for birthdays today or before' do
      e = build(:expert, birthday: 24.years.ago.utc.to_date)
      e.age.should == 24
    end

    it 'should be the age in years for birthdays tomorrow or later' do
      datetime = 24.years.ago + 1.day
      e = build(:expert, birthday: datetime.utc.to_date)
      e.age.should == 23
    end
  end

  describe 'to_s' do
    it 'should be full_name' do
      e = build(:expert)
      e.to_s.should == e.full_name
    end
  end
end
