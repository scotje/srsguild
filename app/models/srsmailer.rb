class Srsmailer < ActionMailer::Base
  def account_create_verify(account, host)
    recipients  account.email
    from        "support@srsguild.com"
    subject     "Please verify your new srsguild.com account!"
    body        :account => account, :host => host
  end  

  def contact_form(from_email, message)
    recipients  "support@srsguild.com"
    from        "support@srsguild.com"
    reply_to    from_email
    subject     "Contact form submission from srsguild.com"
    body        :message => message
  end
  
  def account_password_reset_request(account, host)
    recipients  account.email
    from        "support@srsguild.com"
    subject     "Password reset request from srsguild.com"
    body        :account => account, :host => host
  end
end
