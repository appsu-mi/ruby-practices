# frozen_string_literal: true

class Game
  LAST_FRAME = 10

  def initialize(input_scores)
    @score_board = initialize_frames(input_scores)
  end

  def total_score
    @total_score ||= calc_total_score
  end

  private

  def initialize_frames(input_scores)
    shots =
      input_scores.split(',').map do |point|
        point == 'X' ? [10, 0] : point
      end.flatten

    shots.each_slice(2).map { |one_frame_shots| Frame.new(*one_frame_shots) }
  end

  def calc_total_score
    all_frame_scores = @score_board.map.with_index(1) { |frame, count| calc_score(frame, count) }
    all_frame_scores.flatten.sum
  end

  def calc_score(frame, count)
    count < LAST_FRAME ? [frame.score, calc_bonus_score(frame, count)] : frame.score
  end

  def calc_bonus_score(frame, count)
    next_frame = @score_board[count] if frame.spare? || frame.strike?
    after_next_frame = @score_board[count + 1] if frame.strike?

    bonus_scores = []
    bonus_scores << next_frame.first_point if frame.spare?
    bonus_scores << next_frame.score if frame.strike?
    bonus_scores << after_next_frame.first_point if frame.strike? && next_frame.strike?
    bonus_scores
  end
end
