# frozen_string_literal: true

require 'debug'
require 'pathname'

require_relative 'list_option'
require_relative 'list_module'

Object.include LsCommand

list_options = ListOption.new
path = ARGV[0] || '.'
pathname = Pathname(path)
LsCommand.run(pathname, list_options)
