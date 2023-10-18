# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 3

def main
  r_option = ARGV.getopts('r')['r']
  pattern = '*'
  path = ARGV[0] || '.'
  sorted_files = Dir.glob(pattern, base: path)
  max_length = sorted_files.map(&:length).max
  r_option ? show_ls(sorted_files.reverse, max_length) : show_ls(sorted_files, max_length)
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
