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
      fields = ['emails', 'p_phones', 'b_phones', 'm_phones', 'skypes', 'websites', 'fax']
      expect(Contact::FIELDS.to_a).to match_array(fields)
    end

    it 'should define a method for each field' do
      Contact::FIELDS.each do |field|
        expect(subject).to respond_to(field)
        expect(subject.send(field)).to be_a(Array)
      end
    end
  end

  describe :add do
    context 'when everything is fine' do
      it 'should be the array of values' do
        expect(subject.emails).to be_empty
        expect(subject.add(:emails, 'john@doe.com')).to match_array(['john@doe.com'])
        expect(subject.add(:emails, 'jane@doe.com')).to match_array(['john@doe.com', 'jane@doe.com'])
      end

      it 'should add the value to the contacts' do
        expect(subject.emails).to be_empty
        subject.add(:emails, 'john@doe.com')
        subject.add(:emails, 'jane@doe.com')
        expect(subject.emails).to match_array(['john@doe.com', 'jane@doe.com'])
      end
    end

    context 'when contact already in the field' do#
      before(:each) { subject.emails << 'jane@doe.com' }

      it 'should be false' do
        expect(subject.add(:emails, 'jane@doe.com')).to be_false
      end

      it 'should not add the value to the contacts' do
        subject.add(:emails, 'jane@doe.com')
        expect(subject.emails).to match_array(['jane@doe.com'])
      end
    end

    context 'when the value is blank' do
      it 'should be false' do
        expect(subject.add(:emails, '   ')).to be_false
      end

      it 'should not add the value to the contacts' do
        subject.add(:emails, '        ')
        expect(subject.emails).to be_empty
      end
    end

    context 'when the field is invalid' do
      it 'should be false' do
        expect(subject.add(:invalid, 'jane@doe.com')).to be_false
      end
    end
  end

  describe :add! do
    context 'when everything is fine' do
      it 'should be true' do
        expect(subject.add!(:emails, 'jane@doe.com')).to be_true
      end

      it 'should be saved' do
        expect(subject).to be_new_record
        subject.add!(:emails, 'jane@doe.com')
        expect(subject).to be_persisted
      end
    end

    context 'when something is wrong' do
      it 'should be false' do
        expect(subject.add!(:emails, '         ')).to be_false
      end

      it 'should not be saved' do
        expect(subject).to be_new_record
        subject.add!(:invalid, 'jane@doe.com')
        expect(subject).to be_new_record
      end
    end
  end

  describe :remove do
    context 'when everything is fine' do
      it 'should be the removed value' do
        subject.emails << 'jane@doe.com'
        expect(subject.remove(:emails, 'jane@doe.com')).to eq('jane@doe.com')
      end

      it 'should remove the value from the contacts' do
        subject.emails << 'jane@doe.com'
        subject.remove(:emails, 'jane@doe.com')
        expect(subject.emails).to be_empty
      end
    end

    context 'when the contact is missing' do
      it 'should be nil' do
        expect(subject.remove(:emails, 'jane@doe.com')).to be_nil
      end
    end

    context 'when fiels is invalid' do
      it 'should be false' do
        expect(subject.remove(:invalid, 'jane@doe.com')).to be_false
      end
    end
  end

  describe :remove! do
    context 'when everything is fine' do
      it 'should be true' do
        subject.emails << 'jane@doe.com'
        expect(subject.remove!(:emails, 'jane@doe.com')).to be_true
      end

      it 'should save the record' do
        expect(subject).to be_new_record
        subject.emails << 'jane@doe.com'
        subject.remove!(:emails, 'jane@doe.com')
        expect(subject).to be_persisted
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
