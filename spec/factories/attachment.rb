FactoryGirl.define do
  factory :attachment do
    title    'Some Random File'
    filename 'some-random-file.pdf'

    after(:build) { |attachment| attachment.attachable = build(:expert) }
  end
end
