require 'spec_helper'

describe Comment do
  context 'associations' do
    it { should belong_to(:commentable) }
  end

  describe 'initializers' do
    it 'should auto initialize comment' do
      Comment.new.comment.should be_a(String)
    end
  end

  describe 'to_s' do
    it 'should be the comment' do
      c = build(:comment)
      c.to_s.should == c.comment
    end
  end
end
