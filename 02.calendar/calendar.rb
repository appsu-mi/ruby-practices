#!/usr/bin/env ruby

require 'date'
require 'optparse'

@today = Date.today

def calendar_head(year,month)
  week_a_words = ['日', '月', '火', '水', '木', '金', '土']
  first_day = Date.new(year, month, 1)
  puts "      #{month}月 #{year}"
  week_a_words.each {|word| print word.center(2)}
  puts "\n"
  @one_day_space = ''.center(3)
  @begin_of_month_wday = first_day.wday
end

def begin_of_month_positioning
  number_for_sunday = 0
  number_for_saturday = 6
  first_day = 1
  if @begin_of_month_wday == number_for_sunday
    print "#{first_day}".center(3)
  elsif @begin_of_month_wday == number_for_saturday
    (@begin_of_month_wday).times do
      print @one_day_space
    end
    print "#{first_day}\n".rjust(3)
  else
    (@begin_of_month_wday).times do
      print @one_day_space
    end
    print "#{first_day}".center(3)
  end
end

def show_calendar(year: @today.year , month: @today.month)
  last_day = Date.new(year, month, -1).day
  week_days = 7
  row_count_number = 1

  calendar_head(year,month)

  1.upto(last_day) do |day|
    if day == 1
      begin_of_month_positioning()
    elsif day == (week_days - @begin_of_month_wday)
      print "#{day}\n".rjust(3)
      row_count_number = 1
    elsif row_count_number == week_days
      print "#{day}\n".rjust(3)
      row_count_number = 1
    else
      print "#{day}".center(3)
      row_count_number += 1
    end
  end
end




optional_value = ARGV.getopts('y:m:')
optional_value.compact!
optional_value = optional_value.map {|key,value| [key,value.to_i]}.to_h

unless optional_value['m'].nil?
  unless (1 .. 12).include?(optional_value['m'])
    message = "calendar.rb:#{optional_value['m']}  is neither a month number (1..12) nor a name"
  end
end

if optional_value.empty?
  show_calendar()
else
  if message
    puts message
    return
  elsif optional_value.has_key?('y') && optional_value.has_key?('m')
    show_calendar(year: optional_value['y'],month: optional_value['m'])
  elsif optional_value.has_key?('y')
    show_calendar(year: optional_value['y'])
  elsif optional_value.has_key?('m')
    show_calendar(month: optional_value['m'])
  end
end
