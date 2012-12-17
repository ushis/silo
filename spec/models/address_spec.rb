require 'spec_helper'

describe Address do
  context 'validations' do
    it 'must have a address' do
      a = Address.new
      a.should_not be_valid
      a.errors[:address].should_not be_empty
    end
  end

  context 'associations' do
    it { should belong_to(:country) }
    it { should belong_to(:addressable) }
  end
end
