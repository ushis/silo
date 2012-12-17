require 'spec_helper'

describe Business do
  it 'should act as a tag' do
    Business.acts_as_tag?.should be_true
  end

  context 'associations' do
    it { should have_and_belong_to_many(:partners) }
  end
end
