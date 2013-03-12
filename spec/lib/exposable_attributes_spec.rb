require 'spec_helper'

describe ExposableAttributes do
  class Dummy < ActiveRecord::Base; end

  class DummyWithExposableAttributes < Dummy
    attr_exposable :name, :first_name, :gender, :email, as: :pdf
  end

  class DummyWithHumanMethods < DummyWithExposableAttributes
    def human_gender; end
  end

  describe :exposable_attributes do
    context 'with exposable attributes' do
      subject { DummyWithExposableAttributes.exposable_attributes(*params) }

      context 'without options' do
        let(:params) { [:pdf] }

        it 'should be an array including all exposable attributes' do
          expect(subject).to eq(['name', 'first_name', 'gender', 'email'])
        end
      end

      context 'with the :only option' do
        let(:params) { [:pdf, { only: [:name, :first_name] }] }

        it 'should be an array including only name and first_name' do
          expect(subject).to eq(['name', 'first_name'])
        end
      end

      context 'with the :except option' do
        let(:params) { [:pdf, { except: [:name, :email] }] }

        it 'should be an array including attributes except name and email' do
          expect(subject).to eq(['first_name', 'gender'])
        end
      end
    end

    context 'with human_* methods' do
      subject { DummyWithHumanMethods.exposable_attributes(*params) }

      context 'with the :human option' do
        let(:params) { [:pdf, { human: true, only: [:gender, :email] }] }

        it 'should be an array of attributes with their human methods' do
          expect(subject).to eq([['gender', 'human_gender'], ['email', 'email']])
        end
      end

      context 'without the human option' do
        let(:params) { [:pdf, { only: [:gender, :email] }] }

        it 'should be an array of attributes without their human methods' do
          expect(subject).to eq(['gender', 'email'])
        end
      end
    end
  end
end
