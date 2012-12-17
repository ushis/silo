require 'spec_helper'

describe Adviser do
  it 'should act as a tag' do
    Adviser.acts_as_tag?.should be_true
  end

  context 'associations' do
    it { should have_and_belong_to_many(:partners) }
  end
end
