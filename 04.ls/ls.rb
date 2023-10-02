# frozen_string_literal: true

directory_files = Dir.children(ARGV[0] || '.').reject { |file| file[0] == '.' }.sort
max_length = directory_files.map(&:length).max
column_number = 3

def main(directory_files, column_number, max_length)
  if directory_files.length < column_number
    directory_files.each { |f| f == directory_files.last ? print(f) : printf("%-#{max_length}s\t", f) }
  else
    show_ls(directory_files, column_number, max_length)
  end
end

def show_ls(directory_files, column_number, max_length)
  format_array(directory_files, column_number)[0].zip(*format_array(directory_files, column_number)[1...]) do |row_files|
    row_files.each do |col_file|
      col_file == row_files.last ? print(col_file) : printf("%-#{max_length}s\t", col_file)
    end
    puts
  end
end

def format_array(directory_files, column_number)
  formatted_array = []
  count = 0
  allocate_array_pieces(directory_files.length, column_number).each do |allocated_pieces|
    formatted_array << directory_files[count..(count + allocated_pieces - 1)]
    count += allocated_pieces
  end

  formatted_array
end

def allocate_array_pieces(files_length, column_number)
  allocated_columns = Array.new(column_number) { files_length / column_number }
  if (carry_over = files_length % column_number) != 0
    carry_over.times { |idx| allocated_columns[idx] += 1 }
    return allocated_columns if files_length / column_number == 1 || carry_over == column_number - 1

    allocated_columns.each.with_index do |array, idx|
      next if idx.zero?
      break if idx == allocated_columns.length - 1

      if array != allocated_columns.first
        allocated_columns[idx] += 1
        allocated_columns[-1] -= 1
      end
    end
  end
  allocated_columns
end

main(directory_files, column_number, max_length)
