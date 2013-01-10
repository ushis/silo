require 'spec_helper'

describe AsCsv do
  before(:all) do
    build_model :dummy

    build_model :keyboard do
      string :vendor
      integer :price
      boolean :nice
      has_many :keys, autosave: true, dependent: :destroy
      attr_accessible :vendor, :price, :nice
      attr_accessible :vendor, :price, :nice, as: :exposable
    end

    build_model :key do
      string :code
      integer :keyboard_id
      belongs_to :keyboard
      attr_accessible :code
      attr_accessible :code, as: :exposable
    end

    (1..2).each do |i|
      kb = Keyboard.create!(vendor: "ACME-#{i}", price: i - 2)

      %w(x y z).each { |code| kb.keys.create!(code: code) }
    end

    Keyboard.create!
    Keyboard.create!(vendor: "ACME-3", price: 10, nice: true)
  end

  after(:all) { Keyboard.destroy_all }

  describe :as_csv do
    subject { Keyboard.as_csv(params) }

    context 'without exposable attributes' do
      it 'should raise a SecurityError' do
        expect { Dummy.as_csv }.to raise_error(SecurityError)
      end
    end

    context 'without options' do
      let(:params) { {} }

      it 'should include all exposable attributes' do
        expect(subject).to eq(<<-CSV.strip_heredoc)
          vendor,price,nice
          ACME-1,-1,""
          ACME-2,0,""
          "","",""
          ACME-3,10,true
        CSV
      end

      context 'scoped' do
        subject { Keyboard.limit(2).as_csv }

        it 'should respect the scope' do
          expect(subject).to eq(<<-CSV.strip_heredoc)
            vendor,price,nice
            ACME-1,-1,""
            ACME-2,0,""
          CSV
        end
      end
    end

    context 'with options' do
      let(:params) { { only: :price } }

      it 'should respect them' do
        expect(subject).to eq(<<-CSV.strip_heredoc)
          price
          -1
          0
          ""
          10
        CSV
      end
    end

    context 'with the include option' do
      let(:params) { { include: :keys } }

      it 'should join the association' do
        expect(subject).to eq(<<-CSV.strip_heredoc)
          vendor,price,nice,code
          ACME-1,-1,"",x
          ACME-1,-1,"",y
          ACME-1,-1,"",z
          ACME-2,0,"",x
          ACME-2,0,"",y
          ACME-2,0,"",z
          "","","",
          ACME-3,10,true,
        CSV
      end
    end
  end
end
