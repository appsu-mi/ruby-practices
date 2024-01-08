# frozen_string_literal: true

require 'etc'
require_relative 'file_permission'

class FileInfo
  attr_reader :file_path, :name

  def initialize(path, name)
    @file_path = File.join(path, name)
    @name = File.basename(name)
  end

  def stat
    @stat ||= File.lstat(@file_path)
  end

  def permission = FilePermission.new(stat.mode.to_s(8), stat).to_string

  def nlink = stat.nlink.to_s

  def user = Etc.getpwuid(stat.uid).name

  def group = Etc.getgrgid(stat.gid).name

  def size = stat.size.to_s

  def mtime = stat.mtime

  def blocks = stat.blocks
end
