require 'spec_helper'

describe Privilege do
  describe :associations do
    it { should belong_to(:user) }
  end

  describe :SECTIONS do
    it 'should be an array of sections' do
      expect(Privilege::SECTIONS).to match_array([:partners, :experts, :projects])
    end
  end

  describe :access? do
    context 'by default' do
      it 'should always be false' do
        Privilege::SECTIONS.each do |section|
          expect(subject.access?(section)).to be_false
        end
      end
    end

    context 'as admin' do
      subject { build(:privilege, admin: true) }

      it 'should always be true' do
        Privilege::SECTIONS.each do |section|
          expect(subject.access?(section)).to be_true
        end
      end
    end

    Privilege::SECTIONS.each do |section|
      context "when #{section} is accessible" do
        subject { build(:privilege, section => true) }

        it "should be true for #{section} else false" do
          Privilege::SECTIONS.each do |_section|
            expect(subject.access?(_section)).to eq(_section == section)
          end
        end
      end
    end
  end

  describe :employees do
    context 'by default' do
      it 'should be false' do
        expect(subject.employees).to be_false
      end
    end

    context 'when partners section is accessible' do
      subject { build(:privilege, partners: true) }

      it 'should be true' do
        expect(subject.employees).to be_true
      end
    end
  end
end
