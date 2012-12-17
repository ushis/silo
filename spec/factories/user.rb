FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "john#{n}@doe.com" }
    password 'doe'
    prename  'john'
    name     'doe'
  end

  factory :user_with_login_hash, parent: :user do
    after(:build) { |user| user.refresh_login_hash }
  end
end
