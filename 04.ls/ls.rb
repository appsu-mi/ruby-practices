# frozen_string_literal: true

require 'etc'
require 'optparse'

COLUMN_SIZE = 3

def main
  l_option = ARGV.getopts('l')['l']
  pattern = '*'
  path = ARGV[0] || '.'
  file_names = Dir.glob(pattern, base: path)
  l_option ? show_long_format(path, file_names) : show_short_format(file_names)
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

HALF_YEAR = 15_552_000

FILE_TYPE = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze

PERMISSION = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def show_long_format(path, file_names)
  absolute_path_list = file_names.map { |file_name| File.join(path, file_name) }
  stats_by_path = absolute_path_list.to_h { |absolute_path| [absolute_path, File.lstat(absolute_path)] }
  maxlength_by_section = fetch_maxlength(stats_by_path.values)

  puts "total #{stats_by_path.values.sum(&:blocks)}"
  generate_file_data_list(stats_by_path).each do |file_data|
    puts format_file(file_data, maxlength_by_section)
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
      time_stamp: stat.mtime.strftime(to_timestamp(stat.mtime)),
      file_name: to_file_name(stat, absolute_path)
    }
  end
end

def to_timestamp(mtime)
  (Time.now - mtime) >= HALF_YEAR ? ' %_m %_d  %Y ' : ' %_m %_d %H:%M '
end

def to_file_name(stat, absolute_path)
  file_name = File.basename(absolute_path)
  stat.symlink? ? "#{file_name} -> #{File.readlink(absolute_path)}" : file_name
end

def format_file(file_data, maxlength_by_section)
  space = ' '
  [
    file_data[:permission], space * 2,
    file_data[:link_count].rjust(maxlength_by_section[:link]), space,
    file_data[:owner].ljust(maxlength_by_section[:owner]), space * 2,
    file_data[:group].ljust(maxlength_by_section[:group]), space * 2,
    file_data[:byte_size].rjust(maxlength_by_section[:byte_size]),
    file_data[:time_stamp],
    file_data[:file_name]
  ].join
end

def fetch_maxlength(stat_files)
  length_by_section = { link: 0, owner: 0, group: 0, byte_size: 0 }

  stat_files.each do |stat|
    length_by_section[:link] = stat.nlink.to_s.length if length_by_section[:link] < stat.nlink.to_s.length
    length_by_section[:owner] = Etc.getpwuid(stat.uid).name.length if length_by_section[:owner] < Etc.getpwuid(stat.uid).name.length
    length_by_section[:group] = Etc.getgrgid(stat.gid).name.length if length_by_section[:group] < Etc.getgrgid(stat.gid).name.length
    length_by_section[:byte_size] = stat.size.to_s.length if length_by_section[:byte_size] < stat.size.to_s.length
  end
  length_by_section
end

def to_permission(stat)
  FILE_TYPE[stat.ftype] + divide_character(stat).map do |section, char|
    to_uid_or_gid(stat, section, char) || to_sticky(stat, section, char) || PERMISSION[char]
  end.join
end

def divide_character(stat)
  # mode.to_s(8)の戻り値の文字数は可変なため、末尾から指定しています。
  stat.mode.to_s(8).slice(-3..-1).chars.map.with_index do |char, idx|
    case idx
    when 0 then [:user, char]
    when 1 then [:group, char]
    when 2 then [:other, char]
    end
  end.to_h
end

def to_uid_or_gid(stat, section, char)
  return unless section == :user && stat.setuid? || section == :group && stat.setgid?

  PERMISSION[char].sub(/#{PERMISSION[char].slice(-1)}\z/, to_special_permission(:setuid_gid))
end

def to_sticky(stat, section, char)
  return unless section == :other && stat.sticky?

  PERMISSION[char].sub(/#{PERMISSION[char].slice(-1)}\z/, to_special_permission(:sticky))
end

def to_special_permission(key)
  { setuid_gid: { 'x' => 's', '-' => 'S' }, sticky: { 'x' => 't', '-' => 'T' } }[key]
end

main
