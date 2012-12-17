require 'spec_helper'

describe Language do
  context 'validations' do
    it 'must have a language' do
      l = Language.new
      l.should_not be_valid
      l.errors[:language].should_not be_empty
    end

    it 'must have a unique language' do
      create(:language, language: 'de')

      l = Language.new(language: :de)
      l.should_not be_valid
      l.errors[:language].should_not be_nil
    end
  end

  context 'associations' do
    it { should have_and_belong_to_many(:experts) }
    it { should have_many(:cvs) }
  end

  describe 'PRIORITIES' do
    it 'should be a set of symbols' do
      Language::PRIORITIES.should == [:de, :en, :fr, :es].to_set
    end
  end

  describe 'ordered' do
    it 'should be a collection ordered by human name' do
      hi = create(:language, language: :hi)  # Hindi
      en = create(:language, language: :en)  # English
      de = create(:language, language: :de)  # German
      fr = create(:language, language: :fr)  # French

      Language.all.should =~ [hi, en, de, fr]
      Language.ordered.should == [en, fr, de, hi]
    end
  end

  describe 'priority_ordered' do
    it 'should be a collection ordered by human name and priority' do
      hi = create(:language, language: :hi)  # Hindi
      en = create(:language, language: :en)  # English (prioritized)
      de = create(:language, language: :de)  # German  (prioritized)
      cs = create(:language, language: :cs)  # Czech

      Language.all.should =~ [hi, en, de, cs]
      Language.priority_ordered.should == [en, de, cs, hi]
    end
  end

  describe 'prioritzed?' do
    it 'should be true for prioritized languages' do
      build(:language, language: :en).prioritized?.should be_true
      build(:language, language: :de).prioritized?.should be_true
    end

    it 'should be false for unprioritized languages' do
      build(:language, language: :hi).prioritized?.should be_false
      build(:language, language: :cs).prioritized?.should be_false
    end
  end

  describe 'human' do
    it 'should be the localized language name' do
      l = build(:language, language: :en)
      l.human.should == I18n.t('languages.en')
    end
  end

  describe 'to_s' do
    it 'should be the human name' do
      l = build(:language)
      l.to_s.should == l.human
    end
  end
end
