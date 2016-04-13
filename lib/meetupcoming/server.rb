require 'sinatra/base'
require 'tilt/erb'
require 'securerandom'
require 'redis'
require 'meetupcoming'
require 'meetupcoming/meetup'

module MeetUpcoming
  class Server < Sinatra::Base
    configure do 
      STDOUT.sync = true
      mime_type :ics, 'text/calendar'
      enable :sessions
      set :session_secret, ENV['SECRET']
    end

    get '/' do
      erb :index
    end

    get '/oauth2/callback' do
      meetup.auth_response(params['code'])
      session[:id] = SecureRandom.urlsafe_base64
      redis.setex session[:id], (60*60*24*14), meetup.serialize
      redirect to('/')
    end

    get '/upcoming/:id.ics' do |id|
      pass unless auth(id)

      content_type :ics
      cal = meetup.calendar
    end

    get '/upcoming/:id.json' do |id|
      pass unless auth(id)

      content_type :json
      cal = meetup.calendar
    end

    def meetup
      @meetup ||= Meetup.new(
        ENV['OAUTH_KEY'],
        ENV['OAUTH_SECRET'],
        ENV['HOSTNAME']+'/oauth2/callback')
    end

    def auth_url
      meetup.auth_url
    end

    def upcoming_url
      "#{ENV['HOSTNAME']}/upcoming/#{session[:id]}.ics"
    end

    def logged_in?
      !!session[:id]
    end

    def auth(id)
      token = redis.get id
      return false unless token
      meetup.deserialize(token)
      return true
    end

    def redis
      url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL']
      if url
        @redis ||= Redis.new(:url => url)
      end
    end
  end
end
