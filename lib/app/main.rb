require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'
require 'securerandom'

class Main < Sinatra::Base

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['billing', 'gateway']
    end
  end

  get '/' do
    'Hello'
  end

  get '/validate' do
    protected!

    send(%i(response_ok response_fail response_503 response_timeout).sample)
  end

  def response_ok
    content_type :json

    JSON.dump(
      id: SecureRandom.hex(8),
      paid: true,
      failure_message: nil
    )
  end

  def response_fail
    content_type :json

    JSON.dump(
      id: SecureRandom.hex(8),
      paid: false,
      failure_message: 'insufficient_funds'
    )
  end

  def response_503
    halt 503, 'Service Unavailable'
  end

  def response_timeout
    sleep 15
    halt 503, 'Service Unavailable'
  end
end
