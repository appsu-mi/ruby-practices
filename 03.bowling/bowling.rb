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

frames.each_with_index do |frame, idx|
  index = idx + 1
  if index >= last_frame
    point += frame.sum
  elsif frame[0] == 10 # strike
    strike_point =
      if frames[index][0] == 10
        frame.push(frames[index], frames[index + 1][0]).flatten
      else
        frame + frames[index]
      end
    point += strike_point.sum
  elsif frame.sum == 10 # spare
    spare_point = frame << frames[index][0]
    point += spare_point.sum
  else
    point += frame.sum
  end
end
puts point
