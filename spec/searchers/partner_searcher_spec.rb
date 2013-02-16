require 'spec_helper'

describe PartnerSearcher do
  before(:all) do
    @businesses = %w(Tech Finance Pharma).each_with_object({}) do |val, hsh|
      hsh[val.downcase.to_sym] = create(:business, business: val)
    end

    @acme = build(:partner, company: 'ACME Inc.')
    @acme.businesses = @businesses.values_at(:tech, :finance)
    @acme.save

    @silo = build(:partner, company: 'Silo Inc.')
    @silo.businesses = @businesses.values_at(:tech, :pharma)
    @silo.save
  end

  after(:all) do
    [Business, Partner, User].each { |m| m.destroy_all }
  end

  subject { Partner.search(conditions).all }

  describe :search do
    context 'when searching for company' do
      let(:conditions) { { company: 'CME' } }

      it 'should find partners with partial company names' do
        expect(subject).to match_array([@acme])
      end
    end

    context 'when searching for businesses' do
      context 'when searching for tech' do
        let(:conditions) { { businesses: @businesses.values_at(:tech) } }

        it 'should be silo and acme' do
          expect(subject).to match_array([@acme, @silo])
        end
      end

      context 'when searching for finance' do
        let(:conditions) { { businesses: @businesses.values_at(:finance) } }

        it 'should be acme' do
          expect(subject).to match_array([@acme])
        end
      end

      context 'when searching for finance and pharma' do
        let(:conditions) do
          { businesses: @businesses.values_at(:finance, :pharma) }
        end

        it 'should be acme and silo' do
          expect(subject).to match_array([@acme, @silo])
        end
      end

      context 'when searching for finance, tech and something strange' do
        let(:conditions) do
          { businesses: @businesses.values_at(:finance, :tech, :strange) }
        end

        it 'should be acme and silo' do
          expect(subject).to match_array([@acme, @silo])
        end
      end
    end
  end
end
