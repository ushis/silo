require 'spec_helper'

describe Employee do
  context 'validations' do
    it 'must have a name' do
      e = Employee.new
      e.should_not be_valid
      e.errors[:name].should_not be_empty
    end
  end

  context 'associations' do
    it { should have_one(:contact).dependent(:destroy) }

    it { should belong_to(:partner) }
  end

  describe 'full_name' do
    it 'should be a combination of prename and name' do
      e = build(:employee, prename: 'John', name: 'Doe')
      e.full_name.should == 'John Doe'
    end
  end

  describe 'full_name_with_title' do
    it 'should be full_name, if title is blank' do
      e = build(:employee, prename: 'John', name: 'Doe', title: '')
      e.full_name_with_title.should == e.full_name
    end

    it 'should be a combination of title, prename and name' do
      e = build(:employee, title: 'King', prename: 'John', name: 'Doe')
      e.full_name_with_title.should == 'King John Doe'
    end
  end
end
