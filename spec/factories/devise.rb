Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.define :user do |user|
  user.email         { Factory.next :email }
  user.given_name    { "Joe" }
  user.surname       { "Smith" }
  user.password      { "password" }
  user.confirmed_at  { Time.now }
end

Factory.define :role do |role|
  role.name          { "admin" }
end
