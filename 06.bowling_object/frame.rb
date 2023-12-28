# frozen_string_literal: true

class Frame
  attr_reader :score, :first_point

  PERFECT_SCORE = 10

  def initialize(first_shot, second_shot = 0)
    @first_point = Shot.new(first_shot).point
    @second_point = Shot.new(second_shot).point
    @score = [@first_point, @second_point].sum
  end

  def spare?
    @first_point != PERFECT_SCORE && @score == PERFECT_SCORE
  end

  def strike?
    @first_point == PERFECT_SCORE
  end
end
