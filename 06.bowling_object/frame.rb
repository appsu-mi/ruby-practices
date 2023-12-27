# frozen_string_literal: true

class Frame
  attr_reader :score, :first_point

  def initialize(first_shot, second_shot = Shot.new(0))
    @first_point = first_shot.point
    @second_point = second_shot.point
    @score = [@first_point, @second_point].sum
  end

  def spare?
    @first_point != 10 && @score == 10
  end

  def strike?
    @first_point == 10
  end
end
