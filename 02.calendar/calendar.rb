#!/usr/bin/env ruby

require 'date'
require 'optparse'
WEEK_DAY = 7
WDAY_FOR_SATURDAY = 6
ONE_DAY_SPACE = " " * 3

def calendar_head(year, month)
  week_a_words = ['日', '月', '火', '水', '木', '金', '土']
  puts "#{month}月 #{year}".rjust(13)
  week_a_words.each {|word| print "#{word}".ljust(2)}
  puts "\n"
end

def show_calendar(year:, month:, wday_begin_of_month:)
  last_day = Date.new(year, month, -1).day
  calendar_head(year,month)

  1.upto(last_day) do |day|
    print ONE_DAY_SPACE * wday_begin_of_month if day == 1
    day < 10 ? print("#{day}".center(3)) : print("#{day}".ljust(3))
    if day == (WEEK_DAY - wday_begin_of_month)
      print "\n"
    elsif (day - (WEEK_DAY - wday_begin_of_month)) % WEEK_DAY == 0
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
