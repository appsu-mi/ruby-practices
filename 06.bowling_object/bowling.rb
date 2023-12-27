#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'game'
require_relative 'frame'
require_relative 'shot'

shots =
  ARGV[0].split(',').map do |point|
    point == 'X' ? [Shot.new(10), Shot.new(0)] : Shot.new(point)
  end.flatten

score_board = shots.each_slice(2).map { |one_frame_shots| Frame.new(*one_frame_shots) }

game = Game.new(score_board)

game.run
