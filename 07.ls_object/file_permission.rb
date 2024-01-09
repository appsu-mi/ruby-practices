# frozen_string_literal: true

module FilePermission
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

  def permission_to_string(permission, stat)
    permission_list = divide_sections(permission).map do |section, char|
      to_special_permission(section, char, stat) || PERMISSIONS[char]
    end
    FILE_TYPES[stat.ftype] + permission_list.join
  end

  def divide_sections(permission)
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
