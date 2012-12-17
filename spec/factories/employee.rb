FactoryGirl.define do
  factory :employee do
    prename 'Jane'
    name    'Doe'
    title   'Queen'
    gender  :female

    trait :male do
      prename 'John'
      title   'King'
      gender  :male
    end
  end
end
