# frozen_string_literal: true

COLUMN_NUMBER = 3

def main
  directory_files = Dir.children(ARGV[0] || '.').reject { |file| file[0] == '.' }.sort
  max_length = directory_files.map(&:length).max
  show_ls(directory_files, max_length)
end

def show_ls(directory_files, max_length)
  split_files(directory_files).transpose.each do |row_files|
    row_files.each { |col_file| col_file == row_files.last ? print(col_file) : printf("%-#{max_length}s\t", col_file) }
    puts
  end
end

def split_files(directory_files)
  used_slice_number = (directory_files.length / COLUMN_NUMBER.to_f).ceil
  division_files = directory_files.each_slice(used_slice_number).to_a
  (used_slice_number - division_files[-1].length).times { division_files[-1] << nil }

  division_files
end

main
