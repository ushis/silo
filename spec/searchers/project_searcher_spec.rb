require 'spec_helper'

describe ProjectSearcher do
  before(:all) do
    @europe = build(:project, start: Date.new(1980), end: Date.new(2009), status: :forecast)
    @europe.partners << build(:partner, company: 'ACME')
    @europe.partners << build(:partner, company: 'Linux Foundation')

    @europe.infos << build(:project_info, language: :en, title: 'Europe',
                           funders: 'World Bank',
                           description: 'Crazy Project',
                           service_details: 'Consulting and Management')

    @europe.infos << build(:project_info, language: :de, title: 'Europa',
                           funders: 'Weltbank',
                           description: 'Verrücktes Projekt',
                           service_details: 'Beratung und Management')

    @europe.save

    @america = build(:project, start: Date.new(1950), end: Date.new(1956), status: :complete)
    @america.partners << build(:partner, company: 'Linux Foundation')

    @america.infos << build(:project_info, language: :en, title: 'America',
                            funders: 'EDF',
                            description: 'Holy crap',
                            service_details: 'Consulting')

    @america.infos << build(:project_info, language: :de, title: 'Amerika',
                            funders: 'EDF',
                            description: 'Heilige Scheiße',
                            service_details: 'Beratung')

    @america.infos << build(:project_info, language: :fr, title: 'Amérique',
                            funders: 'EDF',
                            description: 'sainte merde',
                            service_details: 'Conseils')

    @america.save
  end

  after(:all) do
    [Partner, Project, ProjectInfo, User].each { |m| m.destroy_all }
  end

  subject { Project.search(conditions).all }

  describe :search do
    context 'when searching for partial title' do
      let(:conditions) { { title: 'urop' } }

      it 'should find the project with the right title' do
        expect(subject).to eq([@europe])
      end
    end

    context 'when searching for status' do
      let(:conditions) { { status: :complete } }

      it 'should find the project with the correct status' do
        expect(subject).to eq([@america])
      end
    end

    context 'when searching for start' do
      let(:conditions) { { start: '1924' } }

      it 'should find the projects with a start date later than the given year' do
        expect(subject).to eq([@america, @europe])
      end
    end

    context 'when searching for end' do
      let(:conditions) { { end: '1999' } }

      it 'should find the projects with a end date earlier than the given year' do
        expect(subject).to eq([@america])
      end
    end

    context 'when searching full text' do
      let(:conditions) { { q: 'Management' } }

      it 'should find the corerect projects' do
        expect(subject).to eq([@europe])
      end
    end

    context 'when searching full text for funders' do
      let(:conditions) { { q: 'welt' } }

      it 'should find the project with the correct funders' do
        expect(subject).to eq([@europe])
      end
    end

    context 'when searching full text in partners table' do
      let(:conditions) { { q: 'linux' } }

      it 'should find the corerect projects' do
        expect(subject).to eq([@america, @europe])
      end
    end

    context 'when searching full text, start and end' do
      let(:conditions) { { q: 'Conseils Management', start: 1940, end: 2000 } }

      it 'should find the corerect projects' do
        expect(subject).to eq([@america])
      end
    end

    context 'when searching full text and status' do
      let(:conditions) { { q: 'Management', status: :complete } }

      it 'should find the corerect projects' do
        expect(subject).to eq([])
      end
    end
  end
end
