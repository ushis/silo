require 'spec_helper'

describe Area do
  context 'validations' do
    it 'must have an area' do
      a = Area.new
      a.should_not be_valid
      a.errors[:area].should_not be_empty
    end

    it 'must have a unique area' do
      create(:area, area: :EU)

      a = build(:area, area: :EU)
      a.should_not be_valid
      a.errors[:area].should_not be_empty
    end
  end

  context 'associations' do
    it { should have_many(:countries) }
  end

  describe 'with_ordered_countries' do
    it 'should be a collection of areas with ordered countries' do
      af = create(:area, area: :AF)                  # Africa
      eu = create(:area, area: :EU)                  # Europe
      gb = create(:country, country: :GB, area: eu)  # United Kingdom
      de = create(:country, country: :DE, area: eu)  # Germany
      cz = create(:country, country: :CZ, area: eu)  # Czech Republic
      bj = create(:country, country: :BJ, area: af)  # Benin
      ao = create(:country, country: :AO, area: af)  # Angola

      Area.all.should =~ [af, eu]
      Country.all.should =~ [de, gb, cz, bj, ao]

      areas = Area.with_ordered_countries
      areas.should == [af, eu]
      areas[0].countries.should == [ao, bj]
      areas[1].countries.should == [cz, de, gb]
    end
  end

  describe 'human' do
    it 'should be the localized area name' do
      a = build(:area, area: :AF)
      a.human.should == I18n.t('areas.AF')
    end
  end

  describe 'to_s' do
    it 'should be the human area name' do
      a = build(:area)
      a.to_s.should == a.human
    end
  end
end
