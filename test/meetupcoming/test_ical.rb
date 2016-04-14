require 'test_helper'
require 'meetupcoming/ical'
require 'json'

class IcalTest < Minitest::Test

  Data = JSON.parse(File.read('fixtures/cal.json'))

  def setup
    @subject = MeetUpcoming::Ical.new(Data.take(1)).to_s
    puts @subject
  end

  def test_is_calendar
    assert_match 'VCALENDAR', @subject
  end

  def test_has_events
    assert_match 'VEVENT', @subject
  end

  def test_event_name
    assert_match 'Big Data', @subject
  end

  def test_group_name
    assert_match 'Fox Valley Computing Professionals', @subject
  end

  def test_address
    assert_match 'Old Town Pub', @subject
  end

  def test_start
    assert_match '20160413T230000Z', @subject
  end

  def test_end
    assert_match '20160414T020000Z', @subject
  end
end
