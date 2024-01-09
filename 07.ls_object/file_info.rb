# frozen_string_literal: true

require 'etc'
require_relative 'file_permission'

class FileInfo
  include FilePermission
  attr_reader :file_path, :name

  def initialize(file_path)
    @file_path = file_path
    @name = File.basename(file_path)
  end

  def stat
    @stat ||= File.lstat(@file_path)
  end

  def permission = permission_to_string(stat.mode.to_s(8), stat)

  def nlink = stat.nlink.to_s

  def user = Etc.getpwuid(stat.uid).name

  def group = Etc.getgrgid(stat.gid).name

  def size = stat.size.to_s

  def mtime = stat.mtime

  def blocks = stat.blocks
end
