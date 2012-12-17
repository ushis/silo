require 'spec_helper'

describe Privilege do
  context 'associations' do
    it { should belong_to(:user) }
  end

  describe 'SECTIONS' do
    it 'should be an array of sections' do
      Privilege::SECTIONS =~ [:partners, :experts, :references]
    end
  end

  describe 'access?' do
    it 'should always be false by default' do
      privilege = Privilege.new

      Privilege::SECTIONS.each do |section|
        privilege.access?(section).should be_false
      end
    end

    it 'should always be true for admins' do
      privilege = build(:privilege, admin: true)

      Privilege::SECTIONS.each do |section|
        privilege.access?(section).should be_true
      end
    end

    Privilege::SECTIONS.each do |section|
      it "should be true for #{section} else false" do
        privilege = build(:privilege, section => true)

        Privilege::SECTIONS.each do |_section|
          if _section == section
            privilege.access?(_section).should be_true
          else
            privilege.access?(_section).should be_false
          end
        end
      end
    end
  end

  describe 'privileges=' do
    it 'should set admin true' do
      privilege = build(:privilege)
      privilege.privileges = { admin: true }
      privilege.admin?.should be_true
    end

    it 'should set the privileges' do
      privileges = { partners: true, experts: true }
      privilege = build(:privilege)
      privilege.privileges = privileges
      privilege.admin?.should be_false

      Privilege::SECTIONS.each do |section|
        privilege.access?(section).should (privileges[section] ? be_true : be_false)
      end
    end
  end

  describe 'employees' do
    it 'should be false by default' do
      privilege = Privilege.new
      privilege.employees.should be_false
    end

    it 'should be true if the partners section is accessible' do
      privilege = build(:privilege, partners: true)
      privilege.employees.should be_true
    end
  end
end
