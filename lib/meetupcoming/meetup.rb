require 'json'
require 'oauth2'
require 'redis'
require 'securerandom'

module MeetUpcoming
  class Meetup
    ResponseCache = 60*60*24
    AuthCache = 60*60*24*14

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
      @id = SecureRandom.urlsafe_base64
      redis.setex @id, AuthCache, serialize
      return @id
    end

    def calendar
      check_token
      cache(token.token+'cal') do
        token.get('/self/calendar').body
      end
    end

    def auth(id)
      token = redis.get id
      return false unless token
      @id = id
      redis.expire id, AuthCache
      deserialize(token)
      return true
    end

    def check_token
      if token.expired?
        p 'refreshing access token'
        @token = token.refresh! if token.expired?
        redis.setex @id, AuthCache, serialize
      end
    end

    def cache(key)
      return yield unless redis

      cached = redis.get key
      return cached if cached

      response = yield
      redis.setex key, ResponseCache, response
      response
    end

    def redis
      url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL']
      if url
        @redis ||= Redis.new(:url => url)
      end
    end

    def serialize
      JSON.generate(token.to_hash)
    end

    def deserialize(stuff)
      @token = OAuth2::AccessToken.from_hash(client, JSON.parse(stuff))
    end
  end
end
