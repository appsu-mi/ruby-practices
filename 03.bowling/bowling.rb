#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
last_frame = 10

frames.each.with_index(1) do |frame, idx|
  if idx >= last_frame
    point += frame.sum
  elsif frame[0] == 10 # strike
    strike_point =
      if frames[idx][0] == 10
        # チェリー本読んで変えてみた　flatten使わずに　＊へ変更　未コミット
        frame.push(*frames[idx], frames[idx + 1][0])
      else
        frame + frames[idx]
      end
    point += strike_point.sum
  elsif frame.sum == 10 # spare
    spare_point = frame << frames[idx][0]
    point += spare_point.sum
  else
    point += frame.sum
  end
end
puts point
