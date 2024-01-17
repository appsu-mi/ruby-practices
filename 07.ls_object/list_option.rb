# frozen_string_literal: true

require 'optparse'

class ListOption
  def initialize(options)
    @long_format = options['l']
    @reverse = options['r']
    @dot_match = options['a']
  end

  def self.parse!
    new(ARGV.getopts('lra'))
  end

  def long_format? = @long_format

  def reverse? = @reverse

  def dot_match? = @dot_match
end
