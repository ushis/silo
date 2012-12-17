FactoryGirl.define do
  factory :language do
    sequence(:language) { |n| I18n.t(:languages).keys[n] }
  end
end
