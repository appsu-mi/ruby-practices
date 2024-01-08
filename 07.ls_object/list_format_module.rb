# frozen_string_literal: true

require_relative 'file_info'

module ListFormat

  COLUMN_SIZE = 3
  HALF_YEAR = 15_552_000

  def ls_short(pathname, collect_file_names)
    file_info_list = collect_file_list(pathname, collect_file_names)

    split_file_list(file_info_list).transpose.each do |row_files|
      row_files.each.with_index(1) do |col_file, index|
        next if col_file.nil?

        index == row_files.length ? print(col_file.name) : printf("%-#{calc_max_length(file_info_list, :name)}s\t", col_file.name)
      end
      puts
    end
  end

  def collect_file_list(pathname, collect_file_names)
    collect_file_names.map { |file_name| FileInfo.new(pathname, file_name) }
  end

  def split_file_list(file_info_list)
    used_slice_size = (file_info_list.length / COLUMN_SIZE.to_f).ceil
    divided_files = file_info_list.each_slice(used_slice_size).to_a
    (used_slice_size - divided_files[-1].length).times { divided_files[-1] << nil }

    divided_files
  end

  def ls_long(pathname, collect_file_names)
    file_info_list = collect_file_list(pathname, collect_file_names)

    puts "total #{file_info_list.sum(&:blocks)}"
    file_info_list.each do |file_info|
      puts format_long(file_info, find_max_lengths(file_info_list))
    end
  end

  def find_max_lengths(file_info_list)
    sections = %i[nlink user group size]
    sections.map { |key| [key, calc_max_length(file_info_list, key)] }.to_h
  end

  def calc_max_length(file_info_list, section)
    file_info_list.map { |file_info| file_info.send(section).length }.max
  end

  def format_long(file_info, max_lengths)
    [
      file_info.permission,
      "  #{file_info.nlink.rjust(max_lengths[:nlink])}",
      " #{file_info.user.ljust(max_lengths[:user])}",
      "  #{file_info.group.ljust(max_lengths[:group])}",
      "  #{file_info.size.rjust(max_lengths[:size])}",
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
