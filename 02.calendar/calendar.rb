#!/usr/bin/env ruby

require 'date'
require 'optparse'
WEEK_DAY = 7
ONE_DAY_SPACE = " " * 3

def calendar_head(year, month)
  week_a_words = ['日', '月', '火', '水', '木', '金', '土']
  puts ' ' * 6 + "#{month}月 #{year}"
  week_a_words.each {|word| print "#{word} "}
  puts "\n"
end

def show_calendar(year:, month:, wday_begin_of_month:)
  first_week_of_the_month = WEEK_DAY - wday_begin_of_month
  last_day = Date.new(year, month, -1).day
  calendar_head(year,month)
  1.upto(last_day) do |day_count|
    day = Date.new(year, month, day_count)
    print ONE_DAY_SPACE * wday_begin_of_month if day_count == 1
    print day.strftime('%e') + ' '
    if day_count == first_week_of_the_month || (day_count - first_week_of_the_month) % WEEK_DAY == 0
      print "\n"
    end
  end
end

optional_value = ARGV.getopts('y:m:').map { |key, value| [key,value&.to_i] }.to_h
today = Date.today
optional_value['y'] ||= today.year
optional_value['m'] ||= today.month
wday_begin_of_month = Date.new(optional_value['y'], optional_value['m'], 1).wday

show_calendar(year: optional_value['y'], month: optional_value['m'], wday_begin_of_month: wday_begin_of_month)


