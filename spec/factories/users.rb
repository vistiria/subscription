FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name 'Firstname'
    last_name 'Lastname'
    encrypted_card_number '4485057923557660'
    password { Faker::Internet.password }
    subscription_start nil
  end

  trait :with_subscription do
    subscription_start 10.months.ago
  end
end
