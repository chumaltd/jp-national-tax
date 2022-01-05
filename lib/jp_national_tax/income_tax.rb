# frozen_string_literal: true

require 'date'
Dir[File.expand_path("income_tax/income*.rb", __dir__)].each { |f| require_relative(f) }

module JpNationalTax
  module IncomeTax
  MOD_M = [Kouran2020]
  MOD_Y = [Nenmatsu2020]

    module_function

    def calc_kouran(pay_amount, pay_date, partner = false, dependent = 0)
      responsible_mod_monthly(pay_date)
        .send(:monthly_kouran, pay_amount, partner, dependent)
        .to_i
    end

    def year_salary_taxable(income, calc_date)
      salary = responsible_mod_y(calc_date)
                 .send(:年調給与額, income)
      responsible_mod_y(calc_date)
        .send(:給与所得控除後の給与等の金額, salary)
    end

    def basic_deduction(income, calc_date)
      responsible_mod_y(calc_date)
        .send(:基礎控除額, income)
    end

    def year_tax(income_taxable, calc_date)
      income_tax = responsible_mod_y(calc_date)
                     .send(:算出所得税額, income_taxable)
      responsible_mod_y(calc_date)
        .send(:年調年税額, income_tax)
    end

    def responsible_mod_monthly(date = nil)
      responsible_module(date, MOD_M)
    end

    def responsible_mod_y(date = nil)
      responsible_module(date, MOD_Y)
    end

    def responsible_module(date = nil, mod)
      raise UndefinedDateError if date.nil?

      date = Date.parse(date) if date.class.name == 'String'
      rules = mod.map { |mod| [mod.send(:effective_date), mod] }.filter { |a| date >= a[0] }
      raise NoValidModuleError if rules.length <= 0

      rules.sort_by { |a| a[0] }.reverse!.first[1]
    end
  end
end
