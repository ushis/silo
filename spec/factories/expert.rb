FactoryGirl.define do
  factory :expert do
    name 'Doe'
    prename 'John'
    gender :male
    association :user, factory: :user

    trait :female do
      prename 'Jane'
      gender :female
    end
  end
end
