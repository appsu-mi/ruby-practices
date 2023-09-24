# frozen_string_literal: true

DIRECTORY_FILES = Dir.children(ARGV[0] || '.').reject { |file| file[0] == '.' }.sort
MAX_LENGTH = DIRECTORY_FILES.map(&:length).max

def display_ls
  formatting_the_array[0].zip(*formatting_the_array[1...]) do |row_files|
    row_files.each do |col_file|
      col_file == row_files.last ? print(col_file) : printf("%-#{MAX_LENGTH}s\t", col_file)
    end
    puts
  end
end

def formatting_the_array
  formatted_array = []
  count = 0
  allocating_array_pieces(DIRECTORY_FILES.length).each do |allocated_pieces|
    formatted_array << DIRECTORY_FILES[count..(count + allocated_pieces - 1)]
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

if DIRECTORY_FILES.length < COLUMN_PIECES
  DIRECTORY_FILES.each { |f| f == DIRECTORY_FILES.last ? print(f) : printf("%-#{MAX_LENGTH}s\t", f) }
elsif COLUMN_PIECES == 1
  puts DIRECTORY_FILES
else
  display_ls
end
