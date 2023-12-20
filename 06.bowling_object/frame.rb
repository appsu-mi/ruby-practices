# frozen_string_literal: true

class Frame
  attr_reader :score

  def initialize(first_point, second_point = 0)
    @first_point = first_point
    @second_point = second_point
    @score = [@first_point, @second_point].sum
  end

  def strike?
    @first_point == 10
  end

  def spare?
    @first_point != 10 && @score == 10
  end
end
