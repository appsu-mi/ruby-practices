# frozen_string_literal: true

require 'pathname'
require_relative 'file_list'

class LsCommand
  def initialize(path, list_option)
    @pathname = Pathname(path)
    @list_option = list_option
  end

  def self.run(path, list_option)
    new(path, list_option).run
  end

  def run
    file_list = FileList.new(collect_file_paths)
    @list_option.long_format ? file_list.long_format : file_list.short_format
  end

  private

  def collect_file_paths
    pattern = @pathname.join('*')
    params = @list_option.dot_match ? [pattern, File::FNM_DOTMATCH] : [pattern]

    file_paths = Dir.glob(*params).sort
    @list_option.reverse ? file_paths.reverse : file_paths
  end
end
