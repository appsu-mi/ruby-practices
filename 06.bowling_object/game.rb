# frozen_string_literal: true

class Game
  attr_accessor :score

  def initialize(result)
    @score = 0
    @result = result
  end

  def to_board
    point_list =
      @result.split(',').map do |point|
        point == 'X' ? [10, 0] : point.to_i
      end.flatten
    point_list.each_slice(2).to_a
  end

  def entry_score(frame)
    @score += frame.score
  end
end
