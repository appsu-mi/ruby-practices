#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'game'
require_relative 'frame'
require_relative 'shot'

game = Game.new(ARGV[0])

print game.total_score
