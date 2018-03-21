FactoryBot.define do
  factory :appointment do
    sequence(:time) { |n| DateTime.parse("2018-03-21T#{(n % 8) + 9}:00PST") }
    user
    coach { user.coach }
  end
end
