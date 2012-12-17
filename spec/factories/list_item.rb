require 'securerandom'

FactoryGirl.define do
  factory :list_item do
    sequence(:note) { |_| SecureRandom.hex(32) }
    association :list, factory: :list

    after(:build) do |list_item|
      list_item.item = build((rand(2) == 1) ? :expert : :partner)
    end
  end
end
