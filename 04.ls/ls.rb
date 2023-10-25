# frozen_string_literal: true

require 'etc'
require 'optparse'

COLUMN_SIZE = 3

def main
  l_option = ARGV.getopts('l')['l']
  pattern = '*'
  path = ARGV[0] || '.'
  file_names = Dir.glob(pattern, base: path)
  l_option ? load_l_option(path, file_names) : load_ls(file_names)
end

def load_ls(files)
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

def load_l_option(path, file_names)
  stat_files = file_names.map { |file_name| File.lstat("#{path}/#{file_name}") }
  path_to_stat = stat_files.map.with_index { |stat, idx| ["#{path}/#{file_names[idx]}", stat] }.to_h

  puts "total #{stat_files.sum(&:blocks)}"
  load_body(path_to_stat).each do |file_show_data|
    puts format_file(file_show_data, stat_files)
  end
end

def load_body(path_to_stat)
  path_to_stat.map do |absolute_path, stat|
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
  branch_sec = 15_552_000
  (Time.now - mtime) >= branch_sec ? ' %_m %_d  %Y ' : ' %_m %_d %H:%M '
end

def to_file_name(stat, absolute_path)
  file_name = File.basename(absolute_path)
  stat.symlink? ? "#{file_name} -> #{File.readlink(absolute_path)}" : file_name
end

def format_file(file_show_data, stat_files)
  section_to_maxlength = fetch_maxlength(stat_files)
  space = ' '
  [
    file_show_data[:permission], space * 2,
    file_show_data[:link_count].rjust(section_to_maxlength[:link]), space,
    file_show_data[:owner].ljust(section_to_maxlength[:owner]), space * 2,
    file_show_data[:group].ljust(section_to_maxlength[:group]), space * 2,
    file_show_data[:byte_size].rjust(section_to_maxlength[:byte_size]),
    file_show_data[:time_stamp],
    file_show_data[:file_name]
  ].join
end

def fetch_maxlength(stat_files)
  section_to_length = { link: 0, owner: 0, group: 0, byte_size: 0 }

  stat_files.each do |stat|
    section_to_length[:link] = stat.nlink.to_s.length if section_to_length[:link] < stat.nlink.to_s.length
    section_to_length[:owner] = Etc.getpwuid(stat.uid).name.length if section_to_length[:owner] < Etc.getpwuid(stat.uid).name.length
    section_to_length[:group] = Etc.getgrgid(stat.gid).name.length if section_to_length[:group] < Etc.getgrgid(stat.gid).name.length
    section_to_length[:byte_size] = stat.size.to_s.length if section_to_length[:byte_size] < stat.size.to_s.length
  end
  section_to_length
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
