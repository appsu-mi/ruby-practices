# frozen_string_literal: true

require_relative 'file_list'

# 命名がおかしい
module LsCommand
  def self.run(pathname, list_option)
    file_list = FileList.new(collect_file_names(pathname, list_option), pathname)
    list_option.long_format ? file_list.long_format : file_list.short_format
  end

  def collect_file_names(pathname, list_option)
    pattern = pathname.join('*')
    params = list_option.dot_match ? [pattern, File::FNM_DOTMATCH] : [pattern]

    file_names = Dir.glob(*params).sort
    list_option.reverse ? file_names.reverse : file_names
  end
end
