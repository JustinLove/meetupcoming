require 'icalendar2'

module Icalendar2
  module Property
    class Url < Base
      name "URL"
      value :types => [:text]
    end

    class Dtend < Base
      name "DTEND"
      # main code gets these backwards
      value :types => [:date_time, :date]
    end
  end

  module CalendarProperty
    class Calname < Property::Base
      name "X-WR-CALNAME"
      value :types => [:text]
    end
  end
end

module MeetUpcoming
  class Ical
    def initialize(events)
      @events = events
    end

    def to_s
      cal = Icalendar2::Calendar.new
      cal.version 2.0
      cal.prodid "-//Justin Love//MeetUpcoming//EN"
      cal.set_property('calname', "Upcoming Meetups")
      ical = self
      @events.each do |e|
        cal.event do
          uid e['link']
          summary "#{e['name']} -- #{e['group']['name']}"
          description e['description']
          url e['link']
          if e['venue']
            location ical.address(e['venue'])
            if e['venue']['lat']
              geo [e['venue']['lat'], e['venue']['lon']].compact.join(';')
            end
          end
          dtstamp Time.at(e['updated'] / 1000).to_datetime
          dtstart Time.at(e['time'] / 1000).to_datetime
          if e['duration']
            dtend Time.at((e['time'] + e['duration']) / 1000).to_datetime
          end
        end
      end

      cal.to_ical
    end

    def address(v)
      return "#{v['name']}; #{v['address_1']}; #{v['city']}, #{v['state']} #{v['zip']} #{v['localized_country_name']}"
    end
  end
end
