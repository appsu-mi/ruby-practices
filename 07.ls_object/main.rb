# frozen_string_literal: true

require_relative 'ls_command'
require_relative 'list_option'

list_option = ListOption.parse!
path = ARGV[0] || '.'
LsCommand.run(path, list_option)
