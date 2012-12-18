require 'spec_helper'

describe HumanAttributeNames do
  before(:all) do
    I18n.locale = :en
  end

  describe 'human_attribute_names' do
    it 'should be a sentence of localized attribute names' do
      sentence = Expert.human_attribute_names(:prename, :name, :degree)
      expect(sentence).to eq('First Name, Name and Degree')
    end
  end
end
