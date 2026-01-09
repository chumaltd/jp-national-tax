# coding: utf-8
require "date"
require "bigdecimal"

module JpNationalTax #:nodoc:
  module IncomeTax #:nodoc:
    #
    # https://www.nta.go.jp/publication/pamph/gensen/nencho2025/pdf/204.pdf
    #
    module Nenmatsu2025

      module_function

      def effective_date
        Date.parse("2025-12-01")
      end

      # 電子計算機等による年末調整
      #
      def 年調給与額(給与の総額)
        case 給与の総額
        when 1_900_000 .. 6_599_999
          階差 = 4_000
          同一階差の最小値 = 1_900_000
          給与の総額 - ((給与の総額 - 同一階差の最小値) % 階差)
        else
          給与の総額
        end
      end

      # 電子計算機等による年末調整
      #
      def 給与所得控除後の給与等の金額(年調給与額)
        case 年調給与額
        when 0 .. 650_999
          0
        when 651_000 .. 1_899_999
          年調給与額 - 650_000
        when  1_900_000 .. 3_599_999
          (年調給与額 * BigDecimal('0.7') + 80_000).floor
        when  3_600_000 .. 6_599_999
          (年調給与額 * BigDecimal('0.8') - 440_000).floor
        when  6_600_000 .. 8_499_999
          (年調給与額 * BigDecimal('0.9') - 1_100_000).floor
        when  8_500_000 .. 20_000_000
          年調給与額 - 1_950_000
        else
          STDERR.puts '年末調整の対象となりません'
          年調給与額 - 1_950_000
        end
      end

      # https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1199.htm
      #
      def 基礎控除額(所得金額)
        case 所得金額
        when 0 .. 1_320_000
          950_000
        when 1_320_001 .. 3_360_000
          880_000
        when 3_360_001 .. 4_890_000
          680_000
        when 4_890_001 .. 6_550_000
          630_000
        when 6_550_001 .. 23_500_000
          580_000
        when 23_500_001 .. 24_000_000
          480_000
        when 24_000_001 .. 24_500_000
          320_000
        when 24_500_001 .. 25_000_000
          160_000
        else
          0
        end
      end

      # 電子計算機等による年末調整
      #
      def 算出所得税額(課税給与所得金額)
        tax = case 課税給与所得金額
              when 0 .. 1_950_000
                課税給与所得金額 * 0.05
              when 1_950_001 .. 3_300_000
                課税給与所得金額 * 0.1 - 97_500
              when 3_300_001 .. 6_950_000
                課税給与所得金額 * 0.2 - 427_500
              when 6_950_001 .. 9_000_000
                課税給与所得金額 * 0.23 - 636_000
              when 9_000_001 .. 18_000_000
                課税給与所得金額 * 0.33 - 1_536_000
              when 18_000_001 .. 18_050_000
                課税給与所得金額 * 0.4 - 2_796_000
              else
                raise '年末調整の対象となりません'
              end
        (tax / 1000).floor * 1000
      end

      # 電子計算機等による年末調整
      #
      def 年調年税額(年調所得税額)
        (年調所得税額 * BigDecimal('1.021') / 100).floor * 100
      end

    end
  end
end
