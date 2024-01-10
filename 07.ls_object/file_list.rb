# frozen_string_literal: true

require_relative 'file_info'

class FileList
  COLUMN_COUNT = 3
  HALF_YEAR = 15_552_000

  def initialize(file_path_list)
    @file_info_list = file_path_list.map { |file_path| FileInfo.new(file_path) }
  end

  def short_format
    max_file_name = calc_max_length(:name)
    split_column_list.transpose.each do |row_file_list|
      row_file_list.each.with_index(1) do |col_file, count|
        next if col_file.nil?

        count == row_file_list.length ? print(col_file.name) : printf("%-#{max_file_name}s\t", col_file.name)
      end
      puts
    end
  end

  def long_format
    puts "total #{@file_info_list.sum(&:blocks)}"
    @file_info_list.each do |file_info|
      puts build_long_format(file_info, *find_max_lengths)
    end
  end

  private

  def split_column_list
    used_slice_size = (@file_info_list.length / COLUMN_COUNT.to_f).ceil
    divided_files = @file_info_list.each_slice(used_slice_size).to_a
    (used_slice_size - divided_files[-1].length).times { divided_files[-1] << nil }

    divided_files
  end

  def find_max_lengths
    sections = %i[nlink user group size]
    sections.map { |section| calc_max_length(section) }
  end

  def calc_max_length(section)
    @file_info_list.map { |file_info| file_info.send(section).length }.max
  end

  def build_long_format(file_info, max_nlink, max_user, max_group, max_size)
    [
      file_info.type_and_permission,
      "  #{file_info.nlink.rjust(max_nlink)}",
      " #{file_info.user.ljust(max_user)}",
      "  #{file_info.group.ljust(max_group)}",
      "  #{file_info.size.rjust(max_size)}",
      " #{to_timestamp(file_info.mtime)}",
      " #{to_name_or_link(file_info)}"
    ].join
  end

  def to_timestamp(mtime)
    mtime.strftime((Time.now - mtime) >= HALF_YEAR ? '%_m %_d  %Y' : '%_m %_d %H:%M')
  end

  def to_name_or_link(file_info)
    file_info.stat.symlink? ? "#{file_info.name} -> #{File.readlink(file_info.path)}" : file_info.name
  end
end
