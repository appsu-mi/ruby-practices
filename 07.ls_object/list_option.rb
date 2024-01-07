# frozen_string_literal: true

require 'optparse'

class ListOption
  attr_accessor :long_format, :reverse, :dot_match

  def initialize
    options = ARGV.getopts('arl')

    @long_format = options['l']
    @reverse = options['r']
    @dot_match = options['a']
  end
end
