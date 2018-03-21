FactoryBot.define do
  factory :user do
    sequence(:email) {|n| "example#{n}@example.com" }
    password "password"
    coach
  end

  factory :coach do
    sequence(:name) {|n| "Coach #{n}" }
    sequence(:email) {|n| "coach#{n}@example.com" }
  end

end
