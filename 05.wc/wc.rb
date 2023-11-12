# frozen_string_literal: true

require 'optparse'

def main
  options = ARGV.getopts('lwc')

  input_data =
    if ARGV.empty?
      { stdin: ARGF.read }
    else
      ARGV.to_h do |file_name|
        [file_name, File.read(file_name)]
      end
    end
  show_wc(options, input_data)
end

def show_wc(options, input_data)
  build_show_data(options, input_data).each do |name, row_results|
    row_results.each do |col_result|
      print col_result.to_s.rjust(8)
    end
    name == :stdin ? puts : print(" #{name}\n")
  end
end

def build_show_data(options, input_data)
  if input_data.key?(:stdin)
    { stdin: count_show_data(options, input_data[:stdin]) }
  else
    built_data = input_data.transform_values do |file_content|
      count_show_data(options, file_content)
    end

    built_data['total'] = calc_total(built_data.values) if built_data.length >= 2
    built_data
  end
end

def count_show_data(options, file_content)
  results = []
  if options.value?(true)
    results << count_line(file_content) if options['l']
    results << count_word(file_content) if options['w']
    results << count_byte_size(file_content) if options['c']
  else
    results.push(
      count_line(file_content),
      count_word(file_content),
      count_byte_size(file_content)
    )
  end
  results
end

def count_line(file_content)
  file_content.count("\n")
end

def count_word(file_content)
  file_content.split(' ').count
end

def count_byte_size(file_content)
  file_content.bytesize
end

def calc_total(counted_results)
  counted_results.transpose.map(&:sum)
end

main
