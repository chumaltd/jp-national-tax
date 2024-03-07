# frozen_string_literal: true
require "csv"
require "roo"

#
# eTax仕様のXML構造設計書をTSV変換するツール
#

TARGET_COLUMNS = {
  origin: ["タグ名", "レベル", "共通ボキャブラリまたはデータ型", "項番", "備考"],
  dest: ["version", "tag", "level", "struct", "order", "note", "label"],
}

def search_columns(xlsx)
  [].tap do |columns|
    xlsx.each_row_streaming do |row|
      next if row[0].value != "項番"

      TARGET_COLUMNS[:origin].each do |label|
          columns.push row.find_index { |cell| cell.value == label }
      end
      break
    end
  end
end

def collect_rows(xlsx, columns)
  [].tap do |res|
    xlsx.each_row_streaming do |row|
      next unless row[0].value.to_s =~ /^[0-9]+$/

      label = extract_label(row, columns[1], columns[2])
      res.push(columns.map{ |col| row[col].value }.push(label))
    end
  end
end

def extract_label(row, prev, subs)
  (prev+1...subs).map { |idx| row[idx].value }.join("")
end

def sheet_defs(xlsx)
  columns = []
  xlsx.each_row_streaming do |row|
    next if row[0].value != "帳票名称"

    ["様式ＩＤ", "帳票名称", "バージョン"].each do |label|
        columns.push row.find_index { |cell| cell.value == label }
    end
    break
  end

  [].tap { |res|
    xlsx.each_row_streaming do |row|
      next if row[0].value == "帳票名称"

      res.push columns.map { |i| row[i].value }
      break
    end
  }.flatten
end

# ARGV[0]にはExcelファイルのpathを指定
xlsx = Roo::Excelx.new(ARGV[0])
xlsx.each_with_pagename do |name, sheet|
  id, name, version = sheet_defs(xlsx)
  filename = "#{id}-#{version}-#{name.gsub(/\//, '=')[0, 80]}.tsv"
  columns = search_columns(sheet)

  CSV.open(filename, "w", col_sep: "\t") do |csv|
    csv << TARGET_COLUMNS[:dest]
    collect_rows(xlsx, columns).each do |row|
      csv << row.unshift(version)
    end
  end
end
