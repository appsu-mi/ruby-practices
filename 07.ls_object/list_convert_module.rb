# frozen_string_literal: true

module PermissionConvert
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

  def convert(permission, stat)
    permissions = divide_characters(permission).map do |section, char|
      to_special_permission(section, char, stat) || PERMISSIONS[char]
    end
    FILE_TYPES[stat.ftype] + permissions.join
  end

  def divide_characters(permission)
    # mode.to_s(8)の戻り値の文字数は可変なため、末尾から指定しています。
    {
      user: permission[-3],
      group: permission[-2],
      other: permission[-1]
    }
  end

  def to_special_permission(section, char, stat)
    end_char = PERMISSIONS[char][-1]

    if section == :user && stat.setuid? || section == :group && stat.setgid?
      PERMISSIONS[char].sub(/#{end_char}\z/, UID_GIDS)
    elsif section == :other && stat.sticky?
      PERMISSIONS[char].sub(/#{end_char}\z/, STICKYS)
    end
  end
end
