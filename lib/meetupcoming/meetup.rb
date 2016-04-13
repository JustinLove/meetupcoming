require 'json'
require 'oauth2'

module MeetUpcoming
  class Meetup
    def initialize(key, secret, redirect)
      @client = OAuth2::Client.new(key, secret,
        :site => 'https://api.meetup.com',
        :authorize_url => 'https://secure.meetup.com/oauth2/authorize',
        :token_url => 'https://secure.meetup.com/oauth2/access')
      @redirect = redirect
    end

    attr_reader :client
    attr_reader :redirect
    attr_reader :token

    def auth_url
      client.auth_code.authorize_url(:redirect_uri => redirect)
    end

    def auth_response(code)
      @token = client.auth_code.get_token(code, :redirect_uri => redirect)
    end

    def calendar
      token.get('/self/calendar').body
    end

    def serialize
      JSON.generate(token.to_hash)
    end

    def deserialize(stuff)
      @token = OAuth2::AccessToken.from_hash(client, JSON.parse(stuff))
    end
  end
end
