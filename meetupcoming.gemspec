# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meetupcoming/version'

Gem::Specification.new do |spec|
  spec.name          = "meetupcoming"
  spec.version       = MeetUpcoming::VERSION
  spec.authors       = ["Justin Love"]
  spec.email         = ["git@JustinLove.name"]

  spec.summary       = %q{Produce an icalendar feed of all your upcoming events on Meetup.com.}
  spec.description   = %q{Primarily intended to be run as a Heroku app}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = <<FILES.split($/)
lib/meetupcoming/meetup.rb
lib/meetupcoming/server.rb
lib/meetupcoming/version.rb
lib/meetupcoming/views/index.erb
lib/meetupcoming.rb
config.ru
LICENSE.txt
Rakefile
README.md
FILES
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "icalendar2"
  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "oauth2"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "guard-process"
  spec.add_development_dependency "foreman"
end
