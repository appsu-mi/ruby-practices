# frozen_string_literal: true

class FilePermission
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

  def initialize(permission, stat)
    @permission = permission
    @stat = stat
  end

  def to_string
    permissions = divide_characters.map do |section, char|
      to_special_permission(section, char) || PERMISSIONS[char]
    end
    FILE_TYPES[@stat.ftype] + permissions.join
  end

  private

  def divide_characters
    {
      user: @permission[-3],
      group: @permission[-2],
      other: @permission[-1]
    }
  end

  def to_special_permission(section, char)
    end_char = PERMISSIONS[char][-1]

    if section == :user && @stat.setuid? || section == :group && @stat.setgid?
      PERMISSIONS[char].sub(/#{end_char}\z/, UID_GIDS)
    elsif section == :other && @stat.sticky?
      PERMISSIONS[char].sub(/#{end_char}\z/, STICKYS)
    end
  end
end
