require 'spec_helper'

describe ProjectInfo do
  describe :validations do
    it { should ensure_inclusion_of(:language).in_array(%w(de en es fr)) }
    it { should validate_presence_of(:title) }

    describe :language_cannot_be_changed do
      subject { create(:project_info, :with_project, language: :en) }

      context 'when the language has not changed' do
        before { subject.language = 'en' }

        it 'should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'when the language has changed' do
        before { subject.language = 'de' }

        it 'should not be valid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:language]).to_not be_empty
        end
      end
    end
  end

  describe :associations do
    it { should have_one(:description).dependent(:destroy) }
    it { should have_one(:service_details).dependent(:destroy) }

    it { should belong_to(:project) }
  end

  describe :after_save do
    subject { create(:project_info, :with_project) }

    it 'should send :update_title to the project' do
      expect(subject.project).to receive(:update_title)
      subject.save
    end
  end
end
