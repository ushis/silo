require 'spec_helper'

describe ExpertSearcher do
  before(:all) do
    @area = create(:area, area: :EU)

    @countries = [:DE, :US, :GB].inject({}) do |hsh, c|
      hsh[c] = create(:country, country: c, area: @area)
      hsh
    end

    @languages = [:de, :en, :fr, :hi].inject({}) do |hsh, l|
      hsh[l] = create(:language, language: l)
      hsh
    end

    @de_peter = build(:expert, prename: 'Peter', name: 'Griffin')
    @de_peter.country = @countries[:DE]
    @de_peter.languages = @languages.values_at(:de, :en, :fr)
    @de_peter.comment = build(:comment, comment: 'What a nice person.')
    @de_peter.save

    create(:cv, cv: 'I have a beautiful life.', expert: @de_peter, language: @languages[:de])

    @de_jane = build(:expert, prename: 'Jane', name: 'Doe')
    @de_jane.country = @countries[:DE]
    @de_jane.languages = @languages.values_at(:fr, :hi)
    @de_jane.comment = build(:comment, comment: 'She is really smart.')
    @de_jane.save

    create(:cv, cv: 'I was born in the middle of the world.', expert: @de_jane, language: @languages[:en])

    @us_adam = create(:expert, prename: 'Adam', name: 'Pane')
    @us_adam.country = @countries[:US]
    @us_adam.languages = @languages.values_at(:en)
    @us_adam.comment = build(:comment, comment: 'He is a super smart guy.')
    @us_adam.save

    create(:cv, cv: 'I have some beautiful hair.', expert: @us_adam, language: @languages[:en])
  end

  after(:all) do
    [Area, Country, Language, Expert, User].each { |m| m.destroy_all }
  end

  subject { Expert.search(conditions).all }

  describe :search do
    context 'when searching for name' do
      let(:conditions) { { name: 'ane' } }

      it 'should find experts with partial match in name or prename' do
        expect(subject).to match_array([@de_jane, @us_adam])
      end
    end

    context 'when searching for q' do
      let(:conditions) { { q: '+beautiful -hair' } }

      it 'should find experts with fulltext matches' do
        expect(subject).to eq([@de_peter])
      end
    end

    context 'when searching for languages' do
      let(:conditions) { { languages: @languages.values_at(:en, :fr) } }

      it 'should find experts having all those languages' do
        expect(subject).to eq([@de_peter])
      end
    end

    context 'when searching for country' do
      let(:conditions) { { country: @countries.values_at(:DE, :GB) } }

      it 'should find experts living in one of those countries' do
        expect(subject).to match_array([@de_peter, @de_jane])
      end
    end

    context 'when searching for country "US" and q "smart"' do
      let(:conditions) { { country: @countries.values_at(:US), q: 'smart' } }

      it 'should find @us_adam only' do
        expect(subject).to eq([@us_adam])
      end
    end

    context 'when searching for languages ["fr", "hi", "en"]' do
      let(:conditions) { { languages: @languages.values_at(:fr, :hi, :en) } }

      it 'should be empty' do
        expect(subject).to be_empty
      end
    end

    context 'when searching for country "DE", languages ["en"] and q "super"' do
      let(:conditions) do
        {
          country: @countries[:DE],
          languages: @languages.values_at(:en),
          q: 'super'
        }
      end

      it 'should find nothing' do
        expect(subject).to be_empty
      end
    end

    context 'when searching a scoped model' do
      subject { Expert.limit(1).search(country: @countries[:DE]).all }

      it 'should respect the scope' do
        expect(subject).to have(1).item
        expect(subject.first.country).to eq(@countries[:DE])
      end
    end
  end
end
