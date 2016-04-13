require 'sinatra/base'
require 'tilt/erb'
require 'meetupcoming'
require 'meetupcoming/meetup'
require 'pry'

module MeetUpcoming
  class Server < Sinatra::Base
    configure do 
      mime_type :ics, 'text/calendar'
      STDOUT.sync = true
    end

    get '/' do
      erb :index
    end

    get '/oauth2/callback' do
      meetup.auth_response(params['code'])
      p meetup.serialize
      cal = meetup.calendar
      File.write('cal.json', cal)
      redirect to('/')
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
  end
end
