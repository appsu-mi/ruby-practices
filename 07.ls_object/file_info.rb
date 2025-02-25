# frozen_string_literal: true

require 'etc'

class FileInfo
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

  private_constant :FILE_TYPES, :PERMISSIONS, :UID_GIDS, :STICKYS

  attr_reader :path, :name

  def initialize(file_path)
    @path = file_path
    @name = File.basename(file_path)
  end

  def stat
    @stat ||= File.lstat(@path)
  end

  def permission = to_permission(stat.mode.to_s(8))

  def nlink = stat.nlink.to_s

  def user = Etc.getpwuid(stat.uid).name

  def group = Etc.getgrgid(stat.gid).name

  def size = stat.size.to_s

  def mtime = stat.mtime

  def blocks = stat.blocks

  private

  def to_permission(permisson_character)
    permission_list = divide_sections(permisson_character).map do |section, char|
      to_special_permission(section, char) || PERMISSIONS[char]
    end
    FILE_TYPES[stat.ftype] + permission_list.join
  end

  def divide_sections(permisson_character)
    {
      user: permisson_character[-3],
      group: permisson_character[-2],
      other: permisson_character[-1]
    }
  end

  def to_special_permission(section, char)
    end_char = PERMISSIONS[char][-1]

    if section == :user && stat.setuid? || section == :group && stat.setgid?
      PERMISSIONS[char].sub(/#{end_char}\z/, UID_GIDS)
    elsif section == :other && stat.sticky?
      PERMISSIONS[char].sub(/#{end_char}\z/, STICKYS)
    end
  end
end
