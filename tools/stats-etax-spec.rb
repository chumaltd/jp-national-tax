# frozen_string_literal: true
require "csv"

def print_usage
  STDERR.puts "eTax仕様を変換したTSVを集計して、タグの有効バージョンをリストするツール\n"
  STDERR.puts "Usage: ruby stats-etax-spec.rb <帳票コード>"
end

def accumulate_versions(attr, csv)
    csv.each do |row|
      attr[row['tag']] ||= { versions: [] }
      attr[row['tag']][:versions].push(row['version'])
      attr[row['tag']][:label] = row['label']
      attr[row['tag']][:level] = row['level']
      attr[row['tag']][:order] = row['order']
      attr[row['tag']][:struct] = row['struct']
      attr[row['tag']][:note] = row['note']
    end
end

# ARGV[0]には帳票コード（ファイル名の一部）を指定
if ARGV.length < 1
  print_usage
  exit 1
end

attr = {}
Dir.glob("#{ARGV[0]}*.tsv").each do |path|
  CSV.open(path, "r", col_sep: "\t", headers: true) do |csv|
    STDERR.puts "Processing... #{path}"
    accumulate_versions(attr, csv)
  end
end
output = "stats-#{ARGV[0]}.tsv"
CSV.open(output, "w", col_sep: "\t") do |csv|
  csv << ["tag", "count", "level", "versions", "order", "label", "struct", "note"]
  attr.each do |k, v|
    csv << [k, v[:versions].length, v[:level], v[:versions].join(', '), v[:order], v[:label], v[:struct], v[:note]]
  end
end

STDERR.puts "\n#{output} saved"
