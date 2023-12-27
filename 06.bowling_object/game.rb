# frozen_string_literal: true

class Game
  def initialize(score_board)
    @score_board = score_board
    @total_score = 0
  end

  def run
    @score_board.each.with_index(1) { |frame, count| calc_frame(frame, count) }
    print @total_score
  end

  private

  def calc_frame(frame, count)
    entry_score(frame.score)
    entry_bonus(frame, count) if count < 10
  end

  def entry_score(score)
    @total_score += score
  end

  def entry_bonus(frame, count)
    next_frame = @score_board[count] if frame.spare? || frame.strike?
    after_next_frame = @score_board[count + 1] if frame.strike?

    entry_score(next_frame.first_point) if frame.spare?
    entry_score(next_frame.score) if frame.strike?
    entry_score(after_next_frame.first_point) if frame.strike? && next_frame.strike?
  end
end
