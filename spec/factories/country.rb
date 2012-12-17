FactoryGirl.define do
  factory :country do
    sequence(:country) { |n| I18n.t(:countries).keys[n] }
    association :area, factory: :area
  end
end
