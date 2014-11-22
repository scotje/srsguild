require 'test/unit'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../lib/weekly_schedule.rb")

class WeeklyScheduleTest < Test::Unit::TestCase

  include WeeklySchedule
  
  def test_all_weekdays

    # Sunday
    options = {
      :day => Date.civil(2009, 7, 19),
      :first_day_of_week => 7
    }
    assert_equal 19, first_weekday(options).mday

    # Monday through Sunday
    (20..25).each do |d|
      options = {
        :day => Date.civil(2009, 7, d),
        :first_day_of_week => 7
      }
      assert_equal 19, first_weekday(options).mday
    end

    # Monday through Sunday
    (20..26).each do |d|
      options = {
        :day => Date.civil(2009, 7, d),
        :first_day_of_week => 1
      }
      assert_equal 20, first_weekday(options).mday
    end

  end

  def test_only_workdays
    # Monday through Friday
    (20..24).each do |d|
      options = {
        :day => Date.civil(2009, 7, d),
        :only_workdays => true
      }
      assert_equal 20, first_weekday(options).mday
    end

    # Weekends
    (25..26).each do |d|
      options = {
        :day => Date.civil(2009, 7, d),
        :only_workdays => true
      }
      assert_equal 27, first_weekday(options).mday
    end

  end

end
