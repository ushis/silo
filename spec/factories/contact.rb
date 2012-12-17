require 'securerandom'

FactoryGirl.define do
  factory :contact do
    contacts 'emails' => ['hello@world.com']
  end

  factory :contact_with_contacts, parent: :contact do
    after(:build) do |contact|
      Contact::FIELDS.each do |field|
        3.times { contact.send(field) << SecureRandom.hex(32) }
      end
    end
  end
end
