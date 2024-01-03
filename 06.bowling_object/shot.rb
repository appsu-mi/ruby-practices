# frozen_string_literal: true

class Shot
  attr_reader :point

  def initialize(point)
    @point = point.to_i if point.respond_to?(:to_i)
  end
end
