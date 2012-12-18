require 'spec_helper'

describe Contact do
  describe :associations do
    it { should belong_to(:contactable) }
  end

  describe :callbacks do
    it 'should initialize contacts with an empty hash' do
      expect(subject.contacts).to eq({})
    end

    it 'should remove blank elements before saving' do
      subject.emails.concat(['', '    ', 'john@doe.com', nil])
      subject.save
      expect(subject.emails).to eq(['john@doe.com'])
    end
  end

  describe :FIELDS do
    it 'should be an array of fields' do
      fields = [:emails, :p_phones, :b_phones, :m_phones, :skypes, :websites, :fax]
      expect(Contact::FIELDS).to match_array(fields)
    end

    it 'should define a method for each field' do
      Contact::FIELDS.each do |field|
        expect(subject).to respond_to(field)
        expect(subject.send(field)).to be_a(Array)
      end
    end
  end

  describe :field do
    it 'should raise an ArgumentError for invalid fields' do
      expect { subject.field(:invalid) }.to raise_error(ArgumentError)
    end

    it 'should be the same as the method' do
      contact = build(:contact_with_contacts)

      Contact::FIELDS.each do |field|
        value = contact.field(field)
        expect(value).to be_a(Array)
        expect(value).to have_at_least(1).item
        expect(value).to match_array(contact.send(field))
      end
    end
  end

  describe :empty? do
    it 'should be true if there are no contacts' do
      expect(subject).to be_empty
    end

    it 'should be false if there is at least one contact' do
      contact = build(:contact_with_contacts)
      expect(contact).to_not be_empty
    end
  end
end
