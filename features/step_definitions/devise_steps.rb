# General

Then /^I should see error messages$/ do
  step %{I should see "errors prohibited"}
end

Then /^I should see an error message$/ do
  step %{I should see "error prohibited"}
end

# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  user = FactoryGirl.create :user,
    email: email,
    password: password,
    confirmed_at: nil
end 

Given /^I am signed up and confirmed as "(.*)\/(.*)"$/ do |email, password|
  user = FactoryGirl.create :user,
    email: email,
    password: password,
    confirmed_at: Time.now
end

# Session

Then /^I should be signed in$/ do
  step %{I am on the homepage}
  step %{I should see the signout link}
end

Then /^I should be signed out$/ do
  step %{I am on the homepage}
  step %{I should see "Sign in"}
end

When /^session is cleared$/ do
  # TODO: This doesn't work with Capybara
  # TODO: I tried Capybara.reset_sessions! but that didn't work
  #request.reset_session
  #controller.instance_variable_set(:@_current_user, nil)
end

Given /^I have signed in with "(.*)\/(.*)"$/ do |email, password|
  step %{I am signed up and confirmed as "#{email}/#{password}"}
  step %{I sign in as "#{email}/#{password}"}
end

When /^a user "(.*)\/(.*)" already exists$/ do |email, password|
  step %{I am signed up and confirmed as "#{email}/#{password}"}
end

# Emails

Then /^a confirmation message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.confirmation_token.blank?
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
    email.subject =~ /confirm/i
  end
  assert result
end

When /^I follow the confirmation link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  email = user.send_confirmation_instructions
  token = email.body.match(/token=(.*?)\"/)[1]
  visit "/users/confirmation?confirmation_token=#{token}"
end

Then /^a password reset message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.reset_password_token.blank?
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
    email.subject =~ /password/i
  end
  assert result
end

Then /^an unlock message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.unlock_token.blank?
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
    email.subject =~ /unlock/i
  end
  assert result
end

When /^"(.*)" is locked out$/ do |email|
  user = User.find_by_email(email)
  user.failed_attempts = Devise.maximum_attempts
  user.save!
end

When /^I follow the password reset link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  token = user.send_reset_password_instructions
  visit edit_user_password_path(reset_password_token: token)
end

When /^I follow the unlock link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  token = user.resend_unlock_instructions
  visit "/users/unlock?unlock_token=#{token}"
end

Then /^I should be forbidden$/ do
  assert_response :forbidden
end

# Actions

When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  step %{I go to the sign in page}
  step %{I fill in "Email" with "#{email}"}
  step %{I fill in "Password" with "#{password}"}
  step %{I press "Sign in"}
end

When /^I sign out$/ do
  step %{I follow "Sign Out"}
end

When /^I request password reset link to be sent to "(.*)"$/ do |email|
  step %{I go to the password reset request page}
  step %{I fill in "Email" with "#{email}"}
  step %{I press "Send instructions"}
end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  step %{I fill in "New password" with "#{password}"}
  step %{I fill in "Confirm new password" with "#{confirmation}"}
  step %{I press "Change my password"}
end

When /^I request an unlock link to be sent to "(.*)"$/ do |email|
  step %{I go to the resend unlock instructions page}
  step %{I fill in "Email" with "#{email}"}
  step %{I press "Resend"}
end

When /^I return next time$/ do
  step %{session is cleared}
  step %{I go to the homepage}
end
