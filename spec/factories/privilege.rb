FactoryGirl.define do
  factory :privilege do
    admin false
    experts false
    partners false
    projects false
    association :user, factory: :user
  end
end
