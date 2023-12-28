# frozen_string_literal: true

class Game
  LAST_FRAME = 10

  def initialize(stdin)
    @stdin = stdin
    @total_score = 0
  end

  def run
    score_board = format_stdin
    score_board.each.with_index(1) { |frame, count| calc_frame(frame, count, score_board) }

    print @total_score
  end

  private

  def format_stdin
    shots =
      @stdin.split(',').map do |point|
        point == 'X' ? [10, 0] : point
      end.flatten

    shots.each_slice(2).map { |one_frame_shots| Frame.new(*one_frame_shots) }
  end

  def calc_frame(frame, count, score_board)
    entry_score(frame.score)
    entry_bonus(frame, count, score_board) if count < LAST_FRAME
  end

  def entry_score(score)
    @total_score += score
  end

  def entry_bonus(frame, count, score_board)
    next_frame = score_board[count] if frame.spare? || frame.strike?
    after_next_frame = score_board[count + 1] if frame.strike?

    entry_score(next_frame.first_point) if frame.spare?
    entry_score(next_frame.score) if frame.strike?
    entry_score(after_next_frame.first_point) if frame.strike? && next_frame.strike?
  end
end
