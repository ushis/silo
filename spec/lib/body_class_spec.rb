require 'spec_helper'

describe BodyClass::BodyClass do

  it 'should be a subclass of Set' do
    expect(BodyClass::BodyClass.superclass).to eq(Set)
  end

  subject { BodyClass::BodyClass.new(enum) }

  describe 'indifferent access' do
    let(:enum) { [:class1, 'class2'] }

    it 'should treat symbols and string the same' do
      expect(subject).to include(:class1, 'class1', :class2, 'class2')
    end
  end

  describe :delete do
    let(:enum) { [:class1, :class2] }

    context 'when it does not include the value' do
      it 'should be nil' do
        expect(subject.delete(:class3)).to be_nil
      end
    end

    context 'when it does include the value' do
      [:class1, 'class1'].each do |val|
        context "and value is a #{val.class}" do
          it 'should be the value as a string' do
            expect(subject.delete(val)).to eq('class1')
          end
        end
      end
    end
  end

  describe :to_s do
    let(:enum) { %w(class1 class2 class3) }

    it 'should be a string of all values joined by a space' do
      expect(subject.to_s).to eq('class1 class2 class3')
    end
  end
end
