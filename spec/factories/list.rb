FactoryGirl.define do
  factory :list do
    title 'My List'
    private true
    association :user, factory: :user

    trait :public do
      private false
    end
  end

  factory :list_with_items, parent: :list do
    after(:build) do |list|
      4.times { list.list_items << build(:list_item, list: list) }
    end
  end

  factory :list_with_3_items, parent: :list do
    after(:build) do |list|
      3.times { list.list_items << build(:list_item, list: list) }
    end
  end
end
