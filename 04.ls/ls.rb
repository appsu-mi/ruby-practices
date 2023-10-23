# frozen_string_literal: true

require 'etc'
require 'optparse'

COLUMN_SIZE = 3

def main
  l_option = ARGV.getopts('l')['l']
  pattern = '*'
  path = ARGV[0] || '.'
  file_names = Dir.glob(pattern, base: path)
  max_length_name = file_names.map(&:length).max
  l_option ? load_l_option(path, file_names) : show_ls(file_names, max_length_name)
end

def show_ls(files, max_length_name)
  split_files(files).transpose.each do |row_files|
    row_files.each.with_index(1) do |col_file, index|
      next if col_file.nil?

      index == row_files.length ? print(col_file) : printf("%-#{max_length_name}s\t", col_file)
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

PERMISSION = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx',
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze

def load_l_option(path, file_names)
  stat_files = file_names.map { |faile_name| File.lstat("#{path}/#{faile_name}") }
  path_to_stat = stat_files.map.with_index { |stat, idx| ["#{path}/#{file_names.fetch(idx)}", stat] }.to_h

  puts "total #{stat_files.map(&:blocks).sum}"
  load_body(path_to_stat).each do |file|
    puts format_file(file, stat_files)
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
      time_stamp: stat.mtime.strftime(
        Time.now.year == stat.mtime.year ? ' %_m %_d %H:%M ' : ' %_m %_d  %Y '
      ),
      file_name:
        if stat.symlink?
          "#{File.basename(absolute_path)} -> #{File.readlink(absolute_path)}"
        else
          File.basename(absolute_path)
        end
    }
  end
end

def format_file(file, stat_files)
  block_to_maxlength = fetch_max_length(stat_files)
  constant_size = 2
  [
    file.fetch(:permission),
    file.fetch(:link_count).rjust(block_to_maxlength.fetch(:link) + constant_size), ' ',
    file.fetch(:owner).ljust(block_to_maxlength.fetch(:owner)     + constant_size),
    file.fetch(:group).ljust(block_to_maxlength.fetch(:group)     + constant_size),
    file.fetch(:byte_size).rjust(block_to_maxlength.fetch(:byte_size)),
    file.fetch(:time_stamp),
    file.fetch(:file_name)
  ].join
end

def fetch_max_length(stat_files)
  block_to_all_value = { link: [], owner: [], group: [], byte_size: [] }
  stat_files.each do |stat|
    block_to_all_value.fetch(:link)     << stat.nlink
    block_to_all_value.fetch(:owner)    << Etc.getpwuid(stat.uid).name
    block_to_all_value.fetch(:group)    << Etc.getgrgid(stat.gid).name
    block_to_all_value.fetch(:byte_size) << stat.size
  end
  block_to_all_value.transform_values { |values| values.map { |value| value.to_s.length }.max }
end

def to_permission(stat)
  [
    PERMISSION[stat.ftype], divide_character(stat).map do |block, char|
      to_uid_or_gid(stat, block, char) || to_sticky(stat, block, char) || PERMISSION[char]
    end
  ].join
end

def divide_character(stat)
  # mode.to_s(8)の戻り値の文字数は可変なため、末尾から指定しています。
  stat.mode.to_s(8).slice(-3..-1).chars.map.with_index do |char, idx|
    case idx
    when 0 then [:user,  char]
    when 1 then [:group, char]
    when 2 then [:other, char]
    end
  end.to_h
end

def to_uid_or_gid(stat, block, char)
  return unless block == :user && stat.setuid? || block == :group && stat.setgid?

  PERMISSION[char].sub(/#{PERMISSION[char].slice(-1)}\z/, to_special_permission(:setuid_gid))
end

def to_sticky(stat, block, char)
  return unless block == :other && stat.sticky?

  PERMISSION[char].sub(/#{PERMISSION[char].slice(-1)}\z/, to_special_permission(:sticky))
end

def to_special_permission(block)
  { setuid_gid: { 'x' => 's', '-' => 'S' }, sticky: { 'x' => 't', '-' => 'T' } }.fetch(block)
end

main
