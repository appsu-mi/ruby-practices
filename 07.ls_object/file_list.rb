# frozen_string_literal: true

require_relative 'file_info'

class FileList
  COLUMN_SIZE = 3
  HALF_YEAR = 15_552_000

  def initialize(file_list, pathname)
    @file_list = file_list
    @pathname = pathname
  end

  def short_format
    split_file_list.transpose.map do |row_files|
      row_files.map.with_index(1) do |col_file, index|
        next if col_file.nil?

        index == row_files.length ? col_file.name : format("%-#{calc_max_length(:name)}s\t", col_file.name)
      end.join
    end.join("\n")
  end

  def long_format
    [
      "total #{file_info_list.sum(&:blocks)}\n",
      file_info_list.map do |file_info|
        build_long(file_info, *find_max_lengths)
      end.join("\n")
    ]
  end

  private

  def file_info_list
    @file_info_list ||= @file_list.map { |file_name| FileInfo.new(@pathname, file_name) }
  end

  def split_file_list
    used_slice_size = (file_info_list.length / COLUMN_SIZE.to_f).ceil
    divided_files = file_info_list.each_slice(used_slice_size).to_a
    (used_slice_size - divided_files[-1].length).times { divided_files[-1] << nil }

    divided_files
  end

  def find_max_lengths
    sections = %i[nlink user group size]
    sections.map { |section| calc_max_length(section) }
  end

  def calc_max_length(section)
    file_info_list.map { |file_info| file_info.send(section).length }.max
  end

  def build_long(file_info, max_nlink, max_user, max_group, max_size)
    [
      file_info.permission,
      "  #{file_info.nlink.rjust(max_nlink)}",
      " #{file_info.user.ljust(max_user)}",
      "  #{file_info.group.ljust(max_group)}",
      "  #{file_info.size.rjust(max_size)}",
      " #{to_timestamp(file_info)}",
      " #{to_name_or_link(file_info)}"
    ].join
  end

  def to_timestamp(file_info)
    file_info.mtime.strftime((Time.now - file_info.mtime) >= HALF_YEAR ? '%_m %_d  %Y' : '%_m %_d %H:%M')
  end

  def to_name_or_link(file_info)
    file_info.stat.symlink? ? "#{file_info.name} -> #{File.readlink(file_info.file_path)}" : file_info.name
  end
end
