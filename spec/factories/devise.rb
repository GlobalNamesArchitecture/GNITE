FactoryGirl.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email         { FactoryGirl.generate :email }
    given_name    "Joe"
    surname       "Smith"
    password      "password"
    confirmed_at  { Time.now }
  end

  factory :role do
    name          'guest'
  end

end