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

frames = shots.each_slice(2).to_a

point = 0
index_of_last_frame = 9

frames.each.with_index do |frame, idx|
  if idx >= index_of_last_frame
    point += frame.sum
  elsif frame[0] == 10 # strike
    strike_point =
      if frames[idx + 1][0] == 10
        frame + frames[idx + 1] << frames[idx + 2][0]
      else
        frame + frames[idx + 1]
      end
    point += strike_point.sum
  elsif frame.sum == 10 # spare
    spare_point = frame << frames[idx + 1][0]
    point += spare_point.sum
  else
    point += frame.sum
  end
end
puts point
