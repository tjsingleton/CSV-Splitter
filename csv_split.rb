require 'optparse'
require 'rubygems'
require 'fastercsv'

options = {
  :file => ARGV[0],
  :row_count => 800
}

class CSVFile
  def initialize(options = {})
    @options = options
  end

  def split
    partition_lines.each_with_index do |line_group, index|
      write(headers, line_group, index)
    end
  end

  private
  def parse
    FasterCSV.open(@options[:file]) {|file| @lines = file.read }
    @lines.reverse!
    @lines
  end

  def lines
    @lines ||= parse
  end

  def headers
    @headers ||= lines.pop
  end

  def partition_lines
    lines.each_slice(@options[:row_count])
  end

  def write(headers, lines, i)
    Thread.new do
      FasterCSV.open("split-#{i}.csv", 'w') do |out|
         out << headers
         lines.reverse_each {|line| out << line if line }
      end
    end
  end
end

CSVFile.new(options).split