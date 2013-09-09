require 'securerandom'

FactoryGirl.define do
  factory :project_info do
    sequence(:title) { |_| SecureRandom.hex(16) }
    sequence(:language) { |_| ProjectInfo.languages.sample }

    trait :with_project do
      association :project, factory: :project
    end
  end
end
