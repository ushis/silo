require 'securerandom'

FactoryGirl.define do
  factory :project_member do
    sequence(:role) { |_| SecureRandom.hex(16) }
    association :expert, factory: :expert
    association :project, factory: :project
  end
end
