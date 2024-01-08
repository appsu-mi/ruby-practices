# frozen_string_literal: true

require_relative 'list_format_module'

# 命名がおかしい
module LsCommand
  include ListFormat

  def self.run(pathname, list_option)
    if list_option.long_format
      ls_long(pathname, collect_file_names(pathname, list_option))
    else
      ls_short(pathname, collect_file_names(pathname, list_option))
    end
  end

  def collect_file_names(pathname, list_option)
    pattern = pathname.join('*')
    params = list_option.dot_match ? [pattern, File::FNM_DOTMATCH] : [pattern]

    file_names = Dir.glob(*params).sort
    list_option.reverse ? file_names.reverse : file_names
  end
end
