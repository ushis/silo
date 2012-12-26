require 'spec_helper'

describe ActsAsComment do
  before(:all) do
    build_model :dummy_comment do
      integer :commentable_id
      string  :commentable_type
      text    :comment

      acts_as_comment :comment, for: :commentable, polymorphic: true
    end

    build_model :dummy_description do
      integer :dummy_id
      text    :description

      acts_as_comment :description, for: :dummy
    end

    build_model :dummy_text do
      text :text

      acts_as_comment :text
    end

    build_model :dummy do
      string :name

      is_commentable_with :comment, class_name: :DummyComment, autosave: true,
                          dependent: :destroy, as: :commentable
    end
  end

  describe :acts_as_comment do
    describe :associations do
      context 'when no association is specified' do
        it 'should not exist' do
          expect(DummyText.reflect_on_all_associations).to be_empty
        end
      end

      context 'when association is specified' do
        it 'should be present' do
          expect(DummyDescription.new).to belong_to(:dummy)
        end

        context 'and options are given' do
          it 'should be present' do
            reflection = DummyComment.reflect_on_association(:commentable)
            expect(reflection.options[:polymorphic]).to be_true
          end
        end
      end
    end

    describe :acts_as_comment? do
      context 'when model acts as comment' do
        it 'should be true' do
          expect(DummyComment.acts_as_comment?).to be_true
        end
      end

      context 'when model does not act as coment' do
        it 'should not be defined' do
          expect(Dummy).to_not respond_to(:acts_as_comment?)
        end
      end
    end

    describe :write_comment_attribute do
      it 'should assign the stringified value' do
        comment = DummyComment.new
        comment.write_comment_attribute(12)
        expect(comment.comment).to eq('12')
      end
    end

    describe :after_initialize do
      context 'when comment is blank' do
        it 'should initialize comment with an empty string' do
          expect(DummyComment.new.comment).to eq('')
        end
      end

      context 'when comment is not blank' do
        before(:all) { @comment = DummyComment.create(comment: 'Hello') }
        after(:all) { @comment.destroy }

        it 'should not override the comment' do
          expect(@comment.reload.comment).to eq('Hello')
        end
      end
    end

    describe :to_s do
      it 'should be the comment attribute as string' do
        c = DummyComment.new
        expect(c.to_s).to eq('')
        c.comment = 'Example'
        expect(c.to_s).to eq('Example')
        c.comment = 12
        expect(c.to_s).to eq('12')
      end
    end
  end

  describe :is_commentable_with do
    context 'when associated model is invalid' do
      class InvalidDummy < ActiveRecord::Base; end

      context 'when it does not exist' do
        it 'should raise NameError' do
          expect {
            InvalidDummy.is_commentable_with :invalid
          }.to raise_error(NameError)
        end
      end

      context 'when it is not commentable' do
        it 'should raise a NotAComment error' do
          expect {
            InvalidDummy.is_commentable_with :dummy
          }.to raise_error(ActsAsComment::NotAComment)
        end
      end
    end

    context 'when associated model is valid' do
      it 'should define a has_one association' do
        expect(Dummy.new).to have_one(:comment).dependent(:destroy)
      end
    end

    describe :comment_reader do
      context 'when new record' do
        it 'should be a new comment' do
          comment = Dummy.new.comment
          expect(comment).to be_a(DummyComment)
          expect(comment).to be_new_record
        end
      end

      context 'when persisted record' do
        before(:all) do
          @comment = DummyComment.new
          @dummy = Dummy.create(comment: @comment)
        end

        after(:all) { @dummy.destroy }

        it 'should be the comment' do
          expect(@dummy.reload.comment(true)).to eq(@comment)
        end
      end
    end

    describe :comment_writer do
      before(:each) do
        @dummy = Dummy.new
        @comment = DummyComment.new
      end

      context 'when comment is a Comment' do
        it 'should assign the comment' do
          @dummy.comment = @comment
          expect(@dummy.comment).to eq(@comment)
        end
      end

      context 'when comment is not a Comment' do
        it 'should assign the stringified value to the comment' do
          @dummy.comment = 'Example'
          expect(@dummy.comment).to be_a(DummyComment)
          expect(@dummy.comment.to_s).to eq('Example')
        end
      end
    end
  end
end
