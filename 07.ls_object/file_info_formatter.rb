# frozen_string_literal: true

require_relative 'file_info'

class FileInfoFormatter
  HALF_YEAR = 15_552_000

  private_constant :HALF_YEAR

  def initialize(file_info)
    @file_info = file_info
  end

  def formatted_timestamp
    @file_info.mtime.strftime((Time.now - @file_info.mtime) >= HALF_YEAR ? '%_m %_d  %Y' : '%_m %_d %H:%M')
  end

  def formatted_name_or_link
    @file_info.stat.symlink? ? "#{@file_info.name} -> #{File.readlink(@file_info.path)}" : @file_info.name
  end
end
