require 'securerandom'

FactoryGirl.define do
  factory :business do
    sequence(:business) { |_| SecureRandom.hex(32) }
  end
end
