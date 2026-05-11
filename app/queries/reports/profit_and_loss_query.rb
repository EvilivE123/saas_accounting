module Reports
  class ProfitAndLossQuery
    def initialize(organization)
      @organization = organization
    end

    def call
      accounts = @organization.accounts
                              .includes(:account_balance)
                              .where(account_type: [:revenue, :expense])
                              .where(is_active: true)

      build_report(accounts)
    end

    private

    def build_report(accounts)
      revenues = []
      expenses = []
      total_revenue = BigDecimal("0.0")
      total_expense = BigDecimal("0.0")

      accounts.each do |account|
        balance = account.safe_balance
        next if balance.zero?

        if account.revenue?
          revenues << { code: account.code, name: account.name, amount: balance }
          total_revenue += balance
        elsif account.expense?
          expenses << { code: account.code, name: account.name, amount: balance }
          total_expense += balance
        end
      end

      {
        revenues: revenues,
        expenses: expenses,
        total_revenue: total_revenue,
        total_expense: total_expense,
        net_income: total_revenue - total_expense
      }
    end
  end
end