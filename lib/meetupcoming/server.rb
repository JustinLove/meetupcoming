require 'sinatra/base'
require 'tilt/erb'
require 'meetupcoming'
require 'meetupcoming/meetup'
require 'meetupcoming/ical'

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
      session[:id] = meetup.auth_response(params['code'])
      redirect to('/')
    end

    get '/upcoming/:id.ics' do |id|
      pass unless meetup.auth(id)

      content_type :ics
      Ical.new(JSON.parse(meetup.calendar)).to_s
    end

    get '/upcoming/:id.json' do |id|
      pass unless meetup.auth(id)

      content_type :json
      meetup.calendar
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
  end
end
