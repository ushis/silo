require 'spec_helper'

describe AsCsv do
  before(:all) do
    build_model :dummy

    build_model :keyboard do
      string :vendor
      integer :price
      boolean :nice

      attr_accessible :vendor, :price, :nice
      attr_accessible :vendor, :price, :nice, as: :exposable

      has_many :keys, autosave: true, dependent: :destroy
    end

    build_model :key do
      string :code
      integer :keyboard_id

      attr_accessible :code
      attr_accessible :code, as: :exposable

      belongs_to :keyboard
    end
  end

  describe 'as_csv' do
    context 'without exposable attributes' do
      it 'should raise a SecurityError' do
        expect { Dummy.as_csv }.to raise_error(SecurityError)
      end
    end

    context 'with exposable attributes' do
      before(:all) do
        @keyboards = (1..6).map do |i|
          Keyboard.create!(vendor: "ACME #{i}", price: i, nice: i % 2 == 0)
        end
      end

      after(:all) do
        Keyboard.destroy_all
      end

      it 'should be a string' do
        expect(Keyboard.as_csv).to be_a(String)
      end

      it 'should have 7 lines' do
        lines = Keyboard.as_csv.split("\n")
        expect(lines).to have(7).items
      end

      it 'should have 3 lines' do
        lines = Keyboard.limit(2).as_csv.split("\n")
        expect(lines).to have(3).items
      end

      it 'should have all exposable attributes in the first line' do
        attr = Keyboard.as_csv.lines.first.chomp.split(',')
        expect(attr).to eq(['vendor', 'price', 'nice'])
      end

      it 'should have an equal number of cols in each line' do
        Keyboard.as_csv.lines.each do |line|
          expect(line.split(',')).to have(3).items
        end
      end

      it 'should have the exact same rows as expected' do
        Keyboard.as_csv.lines.each_with_index do |line, i|
          next if i == 0
          values = ["ACME #{i}", i, i % 2 == 0]
          expect(line).to eq(CSV.generate_line(values))
        end
      end
    end

    context 'with associations' do
      before(:all) do
        2.times do
          keyboard = Keyboard.create!(vendor: 'ACME', price: 0)
          (1..3).each { |code| keyboard.keys << Key.new(code: code) }
        end
      end

      after(:all) do
        Keyboard.destroy_all
      end

      it 'should have 7 lines' do
        lines = Keyboard.as_csv(include: :keys).split("\n")
        expect(lines).to have(7).items
      end

      it 'should have the exposable attributes of the association in the first line too' do
        attr = Keyboard.as_csv(include: :keys).lines.first.chomp.split(',')
        expect(attr).to eq(['vendor', 'price', 'nice', 'code'])
      end
    end
  end
end
