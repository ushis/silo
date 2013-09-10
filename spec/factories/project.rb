require 'securerandom'

FactoryGirl.define do
  factory :project do
    sequence(:title) { |_| SecureRandom.hex(16) }
    sequence(:carried_proportion) { |_| rand(100) }
    sequence(:status) { |_| Project.status_values.map(&:last).sample }
    association :user, factory: :user

    trait :with_infos do
      after(:build) do |project|
        ProjectInfo.language_values.map(&:last).each do |lang|
          project.infos << build(:project_info, language: lang)
        end
      end
    end

    trait :with_partners do
      after(:build) do |project|
        3.times { project.partners << create(:partner) }
      end
    end
  end
end
