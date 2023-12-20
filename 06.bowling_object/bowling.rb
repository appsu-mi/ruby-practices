#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'game'
require_relative 'frame'

game = Game.new(ARGV[0])

score_board = game.to_board
last_frame = 10

score_board.each.with_index(1) do |shots, count|
  frame = Frame.new(*shots)
  game.entry_score(frame)

  if count < last_frame
    next_shots = score_board[count] if frame.strike? || frame.spare?

    if frame.strike?
      strike_bonus_frame = Frame.new(*next_shots)
      game.entry_score(strike_bonus_frame)

      if frame.strike? && strike_bonus_frame.strike?
        after_next_shots = score_board[count + 1]
        double_strike_bonus = Frame.new(after_next_shots[0])
        game.entry_score(double_strike_bonus)
      end

    elsif frame.spare?
      spare_bonus_frame = Frame.new(next_shots[0])
      game.entry_score(spare_bonus_frame)
    end
  end
end

print game.score
