require 'spec_helper'

describe Country do
  context 'validations' do
    it 'must have a country' do
      c = Country.new
      c.should_not be_valid
      c.errors[:country].should_not be_empty
    end

    it 'must have a unique country' do
      create(:country, country: :DE)

      c = build(:country, country: :DE)
      c.should_not be_valid
      c.errors[:country].should_not be_empty
    end
  end

  context 'associations' do
    it { should have_many(:addresses) }
    it { should have_many(:experts) }
    it { should have_many(:partners) }

    it { should belong_to(:area) }
  end

  describe 'find_country' do
    before do
      eu = create(:area, area: :EU)
      @de = create(:country, country: :DE, area: eu)
      @en = create(:country, country: :EN, area: eu)
      @cz = create(:country, country: :CZ, area: eu)
    end

    it 'should be nil for unknown countries' do
      Country.find_country('XY').should be_nil
    end

    it 'should be the same country' do
      Country.find_country(@de).should == @de
    end

    it 'should be the country with the same id' do
      Country.find_country(@en.id).should == @en
      Country.find_country(@en.id.to_s).should == @en
    end

    it 'should be the country with the same country code' do
      Country.find_country(:CZ).should == @cz
      Country.find_country('CZ').should == @cz
    end
  end

  describe 'human' do
    it 'should be the localized country name' do
      c = build(:country, country: :DE)
      c.human.should == I18n.t('countries.DE')
    end
  end

  describe 'to_s' do
    it 'should be the human country name' do
      c = build(:country)
      c.to_s.should == c.human
    end
  end
end
