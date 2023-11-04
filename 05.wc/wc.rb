# frozen_string_literal: true

require 'optparse'

def main
  options = ARGV.getopts('lwc')

  inputted_data =
    if ARGV.empty?
      ARGF.readlines.join
    else
      ARGV.to_h do |file_name|
        [file_name, File.readlines(file_name).join]
      end
    end
  show_wc(options, inputted_data)
end

def show_wc(options, inputted_data)
  build_show_data(options, inputted_data).each do |row_results|
    row_results.each do |col_value|
      if col_value.instance_of? Integer
        printf('%8s', col_value)
      elsif col_value.instance_of? String
        print(" #{col_value}")
      end
    end
  end
end

def build_show_data(options, inputted_data)
  if inputted_data.instance_of? String
    [count_show_data(options, inputted_data) << "\n"]

  else
    count_results_list = inputted_data.map do |file_name, file_content|
      count_show_data(options, file_content) << "#{file_name}\n"
    end

    count_results_list.length >= 2 ? count_results_list << (calc_total(count_results_list) << "total\n") : count_results_list
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

def calc_total(count_results_list)
  drop_name_results_list = count_results_list.map { |count_results| count_results.select { |v| v.instance_of? Integer } }
  drop_name_results_list.transpose.map(&:sum)
end

main
