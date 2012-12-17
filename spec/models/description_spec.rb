require 'spec_helper'

describe Description do
  context 'associations' do
    it { should belong_to(:partner) }
  end

  describe 'initializers' do
    it 'should auto initialize description' do
      Description.new.description.should be_a(String)
    end
  end

  describe 'to_s' do
    it 'should be the description' do
      d = build(:description)
      d.to_s.should == d.description
    end
  end
end
