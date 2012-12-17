FactoryGirl.define do
  factory :area do
    sequence(:area) { |n| I18n.t(:areas).keys[n] }
  end
end
