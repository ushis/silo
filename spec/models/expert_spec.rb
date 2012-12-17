require 'spec_helper'

describe Expert do
  context 'validations' do
    it 'must have a name' do
      e = Expert.new
      e.should_not be_valid
      e.errors[:name].should_not be_empty
    end
  end

  context 'associations' do
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
