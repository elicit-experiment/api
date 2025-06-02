# frozen_string_literal: true

require 'rest-client'

class ContactMailer < ApplicationMailer
  ELICIT_CONTACT_ADDRESS = 'elicit.experiment@gmail.com'

  def self.send_contact_email(contact_params)
    api_key = ENV.fetch('MAILGUN_API_KEY')
    domain = ENV.fetch('MAILGUN_DOMAIN', 'elicit-experiment.com')
    from_email = ENV.fetch('MAILGUN_FROM_EMAIL', "noreply@#{domain}")

    # Prepare message parameters
    message_params = {
      from: "Elicit Experiment <#{from_email}>",
      to: ELICIT_CONTACT_ADDRESS,
      subject: 'New Contact Form Submission',
      html: generate_email_html(contact_params)
    }

    response = RestClient.post(
      # "https://api.mailgun.net/v3/#{domain}/messages",
      'https://api.mailgun.net/v3/sandboxab9d26bf0a4845768806069c0343fc8a.mailgun.org/messages',
      message_params,
      { Authorization: "Basic #{Base64.strict_encode64("api:#{api_key}")}" }
    )
  end

  private

  def self.generate_email_html(contact_params)
    first_name = contact_params[:firstName]
    last_name = contact_params[:lastName]
    email = contact_params[:email]
    notes = contact_params[:notes]

    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
        </head>
        <body>
          <h1>New Contact Form Submission</h1>
          <p>
            <strong>Name:</strong> #{first_name} #{last_name}<br>
            <strong>Email:</strong> #{email}<br>
          </p>
          
          <h2>Message:</h2>
          <p>#{notes}</p>
        </body>
      </html>
    HTML
  end
end
