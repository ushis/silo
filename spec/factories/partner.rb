FactoryGirl.define do
  factory :partner do
    company 'ACME Inc.'
    association :user, factory: :user
  end
end
