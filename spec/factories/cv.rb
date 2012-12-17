require 'securerandom'

FactoryGirl.define do
  factory :cv do
    cv SecureRandom.hex(32)
    association :language, factory: :language
    association :expert, factory: :expert
  end
end
