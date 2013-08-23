require 'spec_helper'

describe Language do
  describe :validations do
    it 'must have a language' do
      expect(subject).to_not be_valid
      expect(subject.errors[:language]).to_not be_empty
    end

    it 'must have a unique language' do
      create(:language, language: 'de')

      subject.language = :de
      expect(subject).to_not be_valid
      expect(subject.errors).to_not be_nil
    end
  end

  describe :associations do
    it { should have_and_belong_to_many(:experts) }
    it { should have_many(:cvs) }
  end

  describe :PRIORITIES do
    it 'should be a set of symbols' do
      expect(Language::PRIORITIES).to eq(%w(de en fr es).to_set)
    end
  end

  describe :find_language do
   before(:all) do
     @de = create(:language, language: :de)
      @en = create(:language, language: :en)
    end

    after(:all) do
      @de.destroy
      @en.destroy
    end

    context 'when the language exists' do
      it 'should be found by symbol' do
        lang = Language.find_language(:de)
        expect(lang).to eq(@de)
      end

      it 'should be found by string' do
        lang = Language.find_language('de')
        expect(lang).to eq(@de)
      end

      it 'should be found by language' do
        lang = Language.find_language(@en)
        expect(lang).to eq(@en)
      end

      it 'should be found by id' do
        lang = Language.find_language(@de.id)
        expect(lang).to eq(@de)
      end

      it 'should be found by stringified id' do
        lang = Language.find_language(@en.id.to_s)
        expect(lang).to eq(@en)
      end
    end

    context 'when the language does not exist' do
      it 'should be nil' do
        lang = Language.find_language('fr')
        expect(lang).to be_nil
      end
    end
  end

  describe :find_language! do
    before(:all) do
      @de = create(:language, language: :de)
    end

    after(:all) do
      @de.destroy
    end

    context 'when the language exists' do
      it 'should be the language' do
        lang = Language.find_language!(:de)
        expect(lang).to eq(@de)
      end
    end

    context 'when the language does not exist' do
      it 'should raise ActiveRecord::RecordNotFound' do
        expect {
          Language.find_language!(:en)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe :find_languages do
    before(:all) do
      @de = create(:language, language: :de)
      @en = create(:language, language: :en)
      @hi = create(:language, language: :hi)
      @fr = create(:language, language: :fr)
    end

    after(:all) do
      [@de, @en, @hi, @fr].each { |l| l.destroy }
    end

    context 'when searched by a mixed array' do
      it 'should find the languages' do
        languages = Language.find_languages(['de', @en.id, @hi])
        expect(languages).to match_array([@de, @en, @hi])
      end
    end

    context 'when searched by string' do
      it 'should find the languages in the string' do
        languages = Language.find_languages('en hi cz')
        expect(languages).to match_array([@en, @hi])
      end
    end
  end

  describe :prioritized do
    before(:all) do
      @langs = (Language::PRIORITIES + %w('hi it').to_set).map do |l|
        create(:language, language: l)
      end
    end

    after(:all) do
      @langs.each { |l| l.destroy }
    end

    subject { Language.prioritized.pluck(:language) }

    it 'should find all prioritized languages' do
      expect(subject).to match_array(Language::PRIORITIES.to_a)
    end
  end

  describe 'ordered' do
    before(:all) do
      @hi = create(:language, language: :hi)  # Hindi
      @en = create(:language, language: :en)  # English
      @de = create(:language, language: :de)  # German
      @fr = create(:language, language: :fr)  # French
    end

    after(:all) do
      [@hi, @en, @de, @fr].each { |l| l.destroy }
    end

    it 'should be a collection ordered by human name' do
      expect(Language.all).to match_array([@hi, @en, @de, @fr])
      expect(Language.ordered).to eq([@en, @fr, @de, @hi])
    end
  end

  describe 'priority_ordered' do
    before(:all) do
      @hi = create(:language, language: :hi)  # Hindi
      @en = create(:language, language: :en)  # English (prioritized)
      @de = create(:language, language: :de)  # German  (prioritized)
      @cs = create(:language, language: :cs)  # Czech
    end

    after(:all) do
      [@hi, @en, @de, @cs].each { |l| l.destroy }
    end

    it 'should be a collection ordered by human name and priority' do
      expect(Language.all).to match_array([@hi, @en, @de, @cs])
      expect(Language.priority_ordered).to eq([@en, @de, @cs, @hi])
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
