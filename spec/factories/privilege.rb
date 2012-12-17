FactoryGirl.define do
  factory :privilege do
    admin false
    experts false
    partners false
    references false
    association :user, factory: :user
  end
end
