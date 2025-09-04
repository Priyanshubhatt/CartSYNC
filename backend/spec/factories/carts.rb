FactoryBot.define do
  factory :cart do
    association :user
    status { 'active' }

    trait :anonymous do
      user { nil }
    end
  end
end
