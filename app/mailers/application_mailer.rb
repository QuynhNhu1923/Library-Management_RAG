class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("USER_MAILER_USERNAME")
  layout "mailer"
end
