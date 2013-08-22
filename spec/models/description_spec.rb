require 'spec_helper'

describe Description do
  it 'should act as comment' do
    expect(Description.acts_as_comment?).to be_true
  end

  describe :associations do
    it { should belong_to(:describable) }
  end
end
