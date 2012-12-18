require 'spec_helper'

describe ExposableAttributes do
  class Dummy < ActiveRecord::Base
  end

  class DummyWithExposableAttributes < Dummy
    attr_accessible :name, :first_name, :gender, :email, as: :exposable
  end

  class DummyWithHumanMethods < DummyWithExposableAttributes
    def human_gender
    end
  end

  describe 'exposable_attributes' do
    context 'without exposable attributes' do
      it 'should raise a SecurityError' do
        expect { Dummy.exposable_attributes }.to raise_error(SecurityError)
      end
    end

    context 'with exposable attributes' do
      before(:all) do
        @dummy = DummyWithExposableAttributes
      end

      it 'should be an array including all exposable attributes' do
        attr = @dummy.exposable_attributes
        expect(attr).to eq(['name', 'first_name', 'gender', 'email'])
      end

      it 'should be an array including only name and first_name' do
        attr = @dummy.exposable_attributes(only: [:name, :first_name])
        expect(attr).to eq(['name', 'first_name'])
      end

      it 'should be an array including attributes except name and email' do
        attr = @dummy.exposable_attributes(except: [:name, :email])
        expect(attr).to eq(['first_name', 'gender'])
      end
    end

    context 'with human_* methods' do
      before(:all) do
        @dummy = DummyWithHumanMethods
      end

      it 'should be an array including attributes and their human methods' do
        attr = @dummy.exposable_attributes(human: true, only: [:gender, :email])
        expect(attr).to eq([['gender', 'human_gender'], ['email', 'email']])
      end
    end
  end
end
