require 'spec_helper'

describe Partner do
  context 'validations' do
    it 'must have a company' do
      p = Partner.new
      p.should_not be_valid
      p.errors[:company].should_not be_empty
    end
  end

  context 'associations' do
    it { should have_many(:employees).dependent(:destroy) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:list_items).dependent(:destroy) }
    it { should have_many(:lists).through(:list_items) }

    it { should have_one(:description).dependent(:destroy) }
    it { should have_one(:comment).dependent(:destroy) }

    it { should belong_to(:user) }
    it { should belong_to(:country) }
  end

  describe 'to_s' do
    it 'should be company' do
      p = build(:partner)
      p.to_s.should == p.company.to_s
    end
  end
end
