# frozen_string_literal: true

def main
  directory_files = Dir.children(ARGV[0] || '.').reject { |file| file[0] == '.' }.sort
  max_length = directory_files.map(&:length).max
  column_number = 3

  show_ls(directory_files, column_number, max_length)
end

def show_ls(directory_files, column_number, max_length)
  lot_files(directory_files, column_number).transpose.each do |row_files|
    row_files.each { |col_file| col_file == row_files.last ? print(col_file) : printf("%-#{max_length}s\t", col_file) }
    puts
  end
end

def lot_files(directory_files, column_number)
  loted_files = []
  divide_number = divide(directory_files.length, column_number)

  directory_files.each_slice(divide_number) { |files| loted_files << files }
  (divide_number - loted_files[-1].length).times { loted_files[-1] << nil }

  loted_files
end

def divide(files_length, column_number)
  divide_number = files_length / column_number
  (files_length % column_number).zero? ? divide_number : divide_number + 1
end

main
