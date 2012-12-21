require 'spec_helper'

describe Comment do
  it 'should acts as comment' do
    expect(Comment.acts_as_comment?).to be_true
  end

  describe :associations do
    it { should belong_to(:commentable) }
  end
end
