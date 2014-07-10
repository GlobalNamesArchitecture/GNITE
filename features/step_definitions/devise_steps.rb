# General

Then /^I should see error messages$/ do
  Then %{I should see "errors prohibited"}
end

Then /^I should see an error message$/ do
  Then %{I should see "error prohibited"}
end

# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  user = Factory :user,
    email: email,
    password: password,
    confirmed_at: nil
end 

Given /^I am signed up and confirmed as "(.*)\/(.*)"$/ do |email, password|
  user = Factory :user,
    email: email,
    password: password,
    confirmed_at: Time.now
end

# Session

Then /^I should be signed in$/ do
  Given %{I am on the homepage}
  Then %{I should see the signout link}
end

Then /^I should be signed out$/ do
  Given %{I am on the homepage} 
  Then %{I should see "Sign in"} 
end

When /^session is cleared$/ do
  # TODO: This doesn't work with Capybara
  # TODO: I tried Capybara.reset_sessions! but that didn't work
  #request.reset_session
  #controller.instance_variable_set(:@_current_user, nil)
end

Given /^I have signed in with "(.*)\/(.*)"$/ do |email, password|
  Given %{I am signed up and confirmed as "#{email}/#{password}"}
  And %{I sign in as "#{email}/#{password}"}
end

When /^a user "(.*)\/(.*)" already exists$/ do |email, password|
  Given %{I am signed up and confirmed as "#{email}/#{password}"}
end

# Emails

Then /^a confirmation message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.confirmation_token.blank?
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
    email.subject =~ /confirm/i &&
    email.body =~ /#{user.confirmation_token}/
  end
  assert result
end

When /^I follow the confirmation link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit "/users/confirmation?confirmation_token=#{user.confirmation_token}"
end

Then /^a password reset message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.reset_password_token.blank?
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
    email.subject =~ /password/i &&
    email.body =~ /#{user.reset_password_token}/
  end
  assert result
end

Then /^an unlock message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  assert !user.unlock_token.blank?
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
    email.subject =~ /unlock/i &&
    email.body =~ /#{user.unlock_token}/
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
  visit edit_user_password_path(reset_password_token: user.reset_password_token)
end

When /^I follow the unlock link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit "/users/unlock?unlock_token=#{user.unlock_token}"
end

Then /^I should be forbidden$/ do
  assert_response :forbidden
end

# Actions

When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  When %{I go to the sign in page}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Sign in"}
end

When /^I sign out$/ do
  When %{I follow "Sign Out"}
end

When /^I request password reset link to be sent to "(.*)"$/ do |email|
  When %{I go to the password reset request page}
  And %{I fill in "Email" with "#{email}"}
  And %{I press "Send instructions"}
end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  And %{I fill in "New password" with "#{password}"}
  And %{I fill in "Confirm new password" with "#{confirmation}"}
  And %{I press "Change my password"}
end

When /^I request an unlock link to be sent to "(.*)"$/ do |email|
  When %{I go to the resend unlock instructions page}
  And %{I fill in "Email" with "#{email}"}
  And %{I press "Resend"}
end

When /^I return next time$/ do
  When %{session is cleared}
  And %{I go to the homepage}
end
