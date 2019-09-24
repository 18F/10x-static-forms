require "sinatra"
require "sinatra/reloader" if development?
require 'aws-sdk-ses'

get "/" do
  erb :index
end

post "/form-endpoint" do
  # This address must be verified with Amazon SES.
  sender = '10x.static.site@gmail.com'

  form_data = {}
  options = {
    "_to": "andrew.hyder+ses@gsa.gov",  # default
    "_subject": "10x Static Site Demo" # default
  }
  params.each do |key, value|
    if key.start_with? "_"
      options[key] = value
    else
      form_data[key] = value
    end
  end

  ses = Aws::SES::Client.new(region: 'us-east-1')

  # Try to send the email.
  begin
    # Provide the contents of the email.
    response = ses.send_email(
      destination: {
        to_addresses: [
          options["_to"] 
        ]
      },
      message: {
        body: {
          html: {
            charset: 'UTF-8',
            data: form_data.to_s
          }
        },
        subject: {
          charset: 'UTF-8',
          data: options["_subject"]
        }
      },
      source: sender,
      # Uncomment the following line to use a configuration set.
      # configuration_set_name: configsetname,
    )

    puts response


  # If something goes wrong, display an error message.
  rescue Aws::SES::Errors::ServiceError => error
    puts "Email not sent. Error message: #{error}"
  end
  if params[:_redirect]
    redirect params[:_redirect]
  end

  redirect :thanks
  halt 200
end

get "/thanks" do
  erb :thanks
end