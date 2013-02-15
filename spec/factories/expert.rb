require 'securerandom'

FactoryGirl.define do
  factory :expert do
    sequence(:name) { |_| SecureRandom.hex(32) }
    sequence(:prename) { |_| SecureRandom.hex(32) }
    gender :male
    association :user, factory: :user

    trait :female do
      prename 'Jane'
      gender :female
    end
  end
end
