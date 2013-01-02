require 'spec_helper'

describe DiscreteValues do
  before(:all) do
    build_model :discrete_values_dummy do
      string :gender
      string :locale
      string :color
      string :size

      attr_accessible :gender, :locale, :color, :size

      discrete_values :gender, [:female, :male]
      discrete_values :locale, [:en, :de, :fr, :cs], default: :en, i18n_scope: :languages
      discrete_values :color,  [:blue, :red], allow_blank: true
      discrete_values :size,   [:s, :m, :l], validate: false
    end
  end

  describe :validations do
    subject { DiscreteValuesDummy.new }

    it { should ensure_inclusion_of(:gender).matches?(%w(female male)) }
    it { should ensure_inclusion_of(:locale).matches?(%w(en de fr cs)) }
    it { should ensure_inclusion_of(:color).matches?(%w(blue red)) }

    it { should_not ensure_inclusion_of(:size).matches?(%w(s m l)) }
  end

  describe :before_save do
    context 'with the default option' do
      subject { DiscreteValuesDummy.create(params) }

      context 'and an empty value' do
        let(:params) { { gender: :female } }

        it 'should be the default value' do
          expect(subject.locale).to eq('en')
        end
      end

      context 'and a valid value' do
        let(:params) { { gender: :female, locale: :cs } }

        it 'should be the assigned value' do
          expect(subject.locale).to eq('cs')
        end
      end
    end
  end

  describe :convert_discrete_value do
    subject { DiscreteValuesDummy.convert_discrete_value(value) }

    context 'when argument is a sympol' do
      let(:value) { :hello }

      it 'should be a string' do
        expect(subject).to eq('hello')
      end
    end

    [[1, 2, 3], { name: 'Peter' }, true, 12, 'example'].each do |value|
      context "when argument is #{value.inspect}" do
        let(:value) { value }

        it "should be #{value.inspect}" do
          expect(subject).to eq(value)
        end
      end
    end
  end

  describe :discrete_values_for do
    subject { DiscreteValuesDummy.locale_values }

    it 'should be a select box friendly list of all values' do
      expect(subject).to match_array([['English', 'en'], ['German', 'de'], ['French', 'fr'], ['Czech', 'cs']])
    end
  end

  describe :set_default_discrete_value_for do
    subject { DiscreteValuesDummy.new(params) }

    before(:each) { subject.set_default_locale }

    context 'when value is empty' do
      let(:params) { {} }

      it 'should set the default value' do
        expect(subject.locale).to eq('en')
      end
    end

    context 'when value is set' do
      let(:params) { { locale: :example } }

      it 'should be the assigned value' do
        expect(subject.locale).to eq('example')
      end
    end
  end

  describe :read_discrete_value_attribute do
    subject { DiscreteValuesDummy.new(params) }

    context 'with a value' do
      let(:params) { { locale: :xx } }

      it 'should be the value as string' do
        expect(subject.locale).to eq('xx')
      end
    end

    context 'with an empty attribute' do
      let(:params) { {} }

      context 'and no default' do
        it 'should be nil' do
          expect(subject.gender).to be_nil
        end
      end

      context 'and a default' do
        it 'should be the default' do
          expect(subject.locale).to eq('en')
        end
      end
    end
  end

  describe :write_discrete_value_attribute do
    subject { DiscreteValuesDummy.new(params) }

    context 'when a symbol is assigned' do
      let(:params) { { locale: :de } }

      it 'should be a string' do
        expect(subject.read_attribute(:locale)).to eq('de')
      end
    end

    [[1, 2, 3], { num: 12 }, 1, true, 'string'].each do |value|
      context "when #{value.inspect} is assigned" do
        let(:params) { { gender: value } }

        it "should be #{value.inspect}" do
          expect(subject.gender).to eq(value)
        end
      end
    end
  end

  describe :human_discrete_value do
    subject { DiscreteValuesDummy.new(params) }

    context 'when value is nil' do
      let(:params) { {} }

      it 'should be nil' do
        expect(subject.human_gender).to be_nil
      end
    end

    context 'with custom i18n scope' do
      let(:params) { { locale: :de } }

      it 'should use the scope' do
        expect(subject.human_locale).to eq('German')
      end
    end

    context 'without custom i18n scope' do
      let(:params) { { gender: :female } }

      it 'should search the default scopes' do
        expect(subject.human_gender).to eq('Female')
      end
    end
  end
end
