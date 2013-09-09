require 'spec_helper'

describe ProjectMember do
  describe :validations do
    it { should validate_presence_of(:role) }
  end

  describe :associations do
    it { should belong_to(:expert) }
    it { should belong_to(:project) }
  end

  describe :db_indexes do
    it { should have_db_index([:expert_id, :project_id]).unique(true) }
  end

  describe :name do
    subject { create(:project_member) }

    it 'should be the name of the expert' do
      expect(subject.name).to eq(subject.expert.to_s)
    end
  end

  describe :to_s do
    subject { create(:project_member) }

    it 'should the combination of role and name' do
      expect(subject.to_s).to eq("#{subject.name} (#{subject.role})")
    end
  end
end
