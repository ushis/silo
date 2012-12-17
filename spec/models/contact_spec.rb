require 'spec_helper'

describe Contact do
  context 'associations' do
    it { should belong_to(:contactable) }
  end

  context 'callbacks' do
    it 'should initialize contacts with an empty hash' do
      Contact.new.contacts.should == {}
    end

    it 'should remove blank elements before saving' do
      contact = Contact.new
      contact.emails.concat(['', '    ', 'john@doe.com', nil])
      contact.save
      contact.emails.length.should == 1
      contact.emails.first.should == 'john@doe.com'
    end
  end

  describe 'FIELDS' do
    it 'should be an array of fields' do
      Contact::FIELDS.should =~ [:emails, :p_phones, :b_phones, :m_phones, :skypes, :websites, :fax]
    end

    it 'should define a method for each field' do
      contact = Contact.new

      Contact::FIELDS.each do |field|
        contact.should respond_to(field)
        contact.send(field).should be_a(Array)
      end
    end
  end

  describe 'field' do
    it 'should raise an ArgumentError for invalid fields' do
      contact = build(:contact)

      expect { contact.field(:invalid) }.to raise_error(ArgumentError)
    end

    it 'should be the same as the method' do
      contact = build(:contact_with_contacts)

      Contact::FIELDS.each do |field|
        contact.field(field).should be_a(Array)
        contact.field(field).length.should > 0
        contact.field(field).should =~ contact.send(field)
      end
    end
  end

  describe 'empty?' do
    it 'should be false if there is at least one contact' do
      contact = build(:contact_with_contacts)
      contact.should_not be_empty

      contact = Contact.new
      contact.emails << 'hello@world.com'
      contact.should_not be_empty
    end

    it 'should be true if there are no contacts' do
      Contact.new.should be_empty
    end
  end
end
