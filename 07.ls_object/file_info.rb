# frozen_string_literal: true

require 'etc'
require_relative 'file_permission'

class FileInfo
  include FilePermission
  attr_reader :path, :name, :stat, :permission, :nlink, :user, :group, :size, :mtime, :blocks

  def initialize(file_path)
    @path = file_path
    @name = File.basename(file_path)

    @stat = File.lstat(@path)
    @permission = permission_to_string(@stat.mode.to_s(8), @stat)
    @nlink = @stat.nlink.to_s
    @user = Etc.getpwuid(@stat.uid).name
    @group = Etc.getgrgid(@stat.gid).name
    @size = @stat.size.to_s
    @mtime = @stat.mtime
    @blocks = @stat.blocks
  end
end
