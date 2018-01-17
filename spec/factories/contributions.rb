FactoryBot.define do
  factory :contribution do
    date 2.months.ago
    user_id { FactoryBot.create(:user).id }
    pending false
  end

  trait :pending do
    pending true
  end
end
