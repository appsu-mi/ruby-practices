# frozen_string_literal: true

directory_files = Dir.children(ARGV[0] || '.').reject { |file| file[0] == '.' }.sort
MAX_LENGTH = directory_files.map(&:length).max

def main(directory_files)
  if directory_files.length < COLUMN_PIECES
    directory_files.each { |f| f == directory_files.last ? print(f) : printf("%-#{MAX_LENGTH}s\t", f) }
  else
    display_ls(directory_files)
  end
end

def display_ls(directory_files)
  formatting_the_array(directory_files)[0].zip(*formatting_the_array(directory_files)[1...]) do |row_files|
    row_files.each do |col_file|
      col_file == row_files.last ? print(col_file) : printf("%-#{MAX_LENGTH}s\t", col_file)
    end
    puts
  end
end

def formatting_the_array(directory_files)
  formatted_array = []
  count = 0
  allocating_array_pieces(directory_files.length).each do |allocated_pieces|
    formatted_array << directory_files[count..(count + allocated_pieces - 1)]
    count += allocated_pieces
  end

  formatted_array
end

def allocating_array_pieces(files_length)
  allocated_by_columns = Array.new(COLUMN_PIECES) { files_length / COLUMN_PIECES }
  if (carry_over = files_length % COLUMN_PIECES) != 0
    carry_over.times { |idx| allocated_by_columns[idx] += 1 }
    return allocated_by_columns if files_length / COLUMN_PIECES == 1 || carry_over == COLUMN_PIECES - 1

    allocated_by_columns.each.with_index do |array, idx|
      next if idx.zero?
      break if idx == allocated_by_columns.length - 1

      if array != allocated_by_columns.first
        allocated_by_columns[idx] += 1
        allocated_by_columns[-1] -= 1
      end
    end
  end
  allocated_by_columns
end

def determined_column_pieces(calc_space)
  temp_col = 3
  temp_col.times do
    break if temp_col == 1

    (MAX_LENGTH + calc_space) * temp_col >= `tput cols`.to_i ? temp_col -= 1 : break
  end
  temp_col
end

def variable_space
  default_divisor = 8
  if (MAX_LENGTH % default_divisor).zero?
    default_divisor
  else
    (MAX_LENGTH / default_divisor + 1) * default_divisor - MAX_LENGTH
  end
end

COLUMN_PIECES = determined_column_pieces(variable_space)

main(directory_files)
