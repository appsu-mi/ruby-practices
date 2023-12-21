#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'game'
require_relative 'frame'

game = Game.new(ARGV[0])

score_board = game.to_board
last_frame_count = 10

score_board.each.with_index(1) do |shots, count|
  frame = Frame.new(*shots)
  game.entry_score(frame)

  if count < last_frame_count
    next_shots = score_board[count] if frame.spare? || frame.strike?

    if frame.spare?
      spare_bonus_frame = Frame.new(next_shots[0])
      game.entry_score(spare_bonus_frame)

    elsif frame.strike?
      strike_bonus_frame = Frame.new(*next_shots)
      game.entry_score(strike_bonus_frame)

      if frame.strike? && strike_bonus_frame.strike?
        after_next_shots = score_board[count + 1]
        double_strike_bonus = Frame.new(after_next_shots[0])
        game.entry_score(double_strike_bonus)
      end
    end
  end
end

print game.score
