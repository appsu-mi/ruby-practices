# frozen_string_literal: true

COLUMN_SIZE = 3

def main
  files = Dir.children(ARGV[0] || '.').reject { |file| file[0] == '.' }.sort
  max_length = files.map(&:length).max
  show_ls(files, max_length)
end

def show_ls(files, max_length)
  split_files(files).transpose.each do |row_files|
    row_files.each.with_index(1) do |col_file, index|
      next if col_file.nil?

      index == row_files.length ? print(col_file) : printf("%-#{max_length}s\t", col_file)
    end
    puts
  end
end

def split_files(files)
  used_slice_size = (files.length / COLUMN_SIZE.to_f).ceil
  divided_files = files.each_slice(used_slice_size).to_a
  (used_slice_size - divided_files[-1].length).times { divided_files[-1] << nil }

  divided_files
end

main
