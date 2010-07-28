auth = YAML.load(File.read(File.join(Rails.root, "..", "..", "shared", "config", "smtp_settings.yml")))

ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'your.host.name',
  :user_name            => auth[:user_name],
  :password             => auth[:password],
  :authentication       => 'plain',
  :enable_starttls_auto => true
}
