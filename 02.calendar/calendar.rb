#!/usr/bin/env ruby

require 'date'
require 'optparse'


def calendar_head(year, month)
  week_a_words = ['日', '月', '火', '水', '木', '金', '土']
  puts "#{month}月 #{year}".rjust(13)
  week_a_words.each {|word| print "#{word}".ljust(2)}
  puts "\n"
end


def begin_of_month_positioning(wday_begin_of_month)
  one_day_space = "\s" * 3
  (wday_begin_of_month).times do
    print one_day_space
  end
end


def show_calendar(year:, month:, wday_begin_of_month:)
  last_day = Date.new(year, month, -1).day
  week_days = 7
  row_count_number = 1
  wday_for_saturday = 6

  calendar_head(year,month)
  1.upto(last_day) do |day|
    if day == 1
      begin_of_month_positioning(wday_begin_of_month)
      print "#{day}".center(3)
      print "\n" if wday_begin_of_month == wday_for_saturday
    elsif day == (week_days - wday_begin_of_month) || row_count_number == week_days
      print "#{day}\n".rjust(3)
      row_count_number = 1
    else
      print "#{day}".center(3)
      row_count_number += 1
    end
  end
end


optional_value = ARGV.getopts('y:m:')
today = Date.today
optional_value['y'] ||= today.year
optional_value['m'] ||= today.month

if optional_value['y'].is_a?(String) || optional_value['m'].is_a?(String)
  optional_value = optional_value.map {|key,value| [key,value.to_i]}.to_h
end
wday_begin_of_month = Date.new(optional_value['y'], optional_value['m'], 1).wday

unless optional_value['m'].nil?
  unless (1 .. 12).include?(optional_value['m'])
    message = "calendar.rb:#{optional_value['m']}  is neither a month number (1..12) nor a name"
  end
end

if message
  puts message
  return
else
  show_calendar(year: optional_value['y'], month: optional_value['m'], wday_begin_of_month: wday_begin_of_month)
end
