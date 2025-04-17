# frozen_string_literal: true
require "csv"
require "roo"

#
# eTax仕様の手続内帳票対応表をTSV変換するツール
#
def print_usage
  # ARGV[1..]にはExcelファイルのpathを指定
  STDERR.puts "Usage: ruby analyze-templates-by-proc.rb <手続code> <手続内帳票対応表.xlsx files>"
end

def search_proc(sheet, proc_id)
  {}.tap do |templates|
    sheet.each do |row|
      next if row[0] != proc_id

      if templates[row[2]]
        templates[row[2]][:template_ver].push(row[9])
      else
        template = { :name => row[1], :proc_ver => row[8], :template_ver => Array(row[9]) }
        templates[row[2]] = template
      end
    end
    if templates.empty?
      STDERR.puts "  #{proc_id} not found"
      return nil 
    end
  end
end

if ARGV.length < 2
  print_usage
  exit 1
end

proc_id = ARGV[0]
filename = "#{proc_id}.tsv"
[].tap do |procs|
  ARGV[1..-1].each do |path|
    xlsx = Roo::Excelx.new(path, expand_merged_ranges: true)
    STDERR.puts "Processing... #{path}"
    xlsx.each_with_pagename do |name, sheet|
      procedure = search_proc(sheet, proc_id)
      procs.push(procedure) if procedure
    end
  end

  keys = procs.map {|procedure| procedure.keys }.flatten.uniq.sort

  CSV.open(filename, "w", col_sep: "\t", force_quotes: true, quote_char: '"') do |csv|
    csv << ["帳票ID", "帳票名"].concat(procs.map {|procedure| procedure.first&.last&.fetch(:proc_ver)})
    keys.each do |k|
      name = procs.map {|procedure| procedure.dig(k, :name) }.compact.first
      csv << [k, name].concat(procs.map {|procedure| procedure[k]&.fetch(:template_ver)&.join('|')})
    end
  end
end

STDERR.puts "\n#{filename} saved"
