# frozen_string_literal: true

require 'etc'
require 'optparse'

COLUMN_SIZE = 3
HALF_YEAR = 15_552_000

FILE_TYPES = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze

PERMISSIONS = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

UID_GIDS = { 'x' => 's', '-' => 'S' }.freeze

STICKYS = { 'x' => 't', '-' => 'T' }.freeze

def main
  options = ARGV.getopts('arl')

  path = ARGV[0] || '.'
  pattern = ['*']
  pattern << '.*' if options['a']

  file_names = Dir.glob(pattern, base: path).sort
  sorted_file_names = options['r'] ? file_names.reverse : file_names

  options['l'] ? show_long_format(path, sorted_file_names) : show_short_format(sorted_file_names)
end

def show_short_format(files)
  max_length = files.map(&:length).max
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

def show_long_format(path, file_names)
  stats_by_path = file_names.to_h do |file_name|
    absolute_path = File.join(path, file_name)
    [absolute_path, File.lstat(absolute_path)]
  end
  file_data_list = generate_file_data_list(stats_by_path)
  max_lengths = calc_max_lengths(file_data_list)

  puts "total #{stats_by_path.values.sum(&:blocks)}"
  file_data_list.each do |file_data|
    puts format_file(file_data, max_lengths)
  end
end

def generate_file_data_list(stats_by_path)
  stats_by_path.map do |absolute_path, stat|
    {
      permission: to_permission(stat),
      link_count: stat.nlink.to_s,
      owner: Etc.getpwuid(stat.uid).name,
      group: Etc.getgrgid(stat.gid).name,
      byte_size: stat.size.to_s,
      time_stamp: to_timestamp(stat.mtime),
      file_name: to_file_name(stat, absolute_path)
    }
  end
end

def to_timestamp(mtime)
  mtime.strftime((Time.now - mtime) >= HALF_YEAR ? ' %_m %_d  %Y ' : ' %_m %_d %H:%M ')
end

def to_file_name(stat, absolute_path)
  file_name = File.basename(absolute_path)
  stat.symlink? ? "#{file_name} -> #{File.readlink(absolute_path)}" : file_name
end

def to_permission(stat)
  permissions = divide_characters(stat).map do |section, char|
    to_special_permission(stat, section, char) || PERMISSIONS[char]
  end
  FILE_TYPES[stat.ftype] + permissions.join
end

def divide_characters(stat)
  # mode.to_s(8)の戻り値の文字数は可変なため、末尾から指定しています。
  permisson_character = stat.mode.to_s(8)
  {
    user: permisson_character[-3],
    group: permisson_character[-2],
    other: permisson_character[-1]
  }
end

def to_special_permission(stat, section, char)
  end_char = PERMISSIONS[char][-1]

  if section == :user && stat.setuid? || section == :group && stat.setgid?
    PERMISSIONS[char].sub(/#{end_char}\z/, UID_GIDS)
  elsif section == :other && stat.sticky?
    PERMISSIONS[char].sub(/#{end_char}\z/, STICKYS)
  end
end

def calc_max_lengths(file_data_list)
  lengths = { link_count: [], owner: [], group: [], byte_size: [] }

  file_data_list.each do |file_data|
    lengths[:link_count] << file_data[:link_count]
    lengths[:owner] << file_data[:owner]
    lengths[:group] << file_data[:group]
    lengths[:byte_size] << file_data[:byte_size]
  end
  lengths.transform_values { |section_values| section_values.map(&:length).max }
end

def format_file(file_data, max_lengths)
  space = ' '
  [
    file_data[:permission], space * 2,
    file_data[:link_count].rjust(max_lengths[:link_count]), space,
    file_data[:owner].ljust(max_lengths[:owner]), space * 2,
    file_data[:group].ljust(max_lengths[:group]), space * 2,
    file_data[:byte_size].rjust(max_lengths[:byte_size]),
    file_data[:time_stamp],
    file_data[:file_name]
  ].join
end

main
