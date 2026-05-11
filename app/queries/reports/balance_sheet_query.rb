module Reports
  class BalanceSheetQuery
    def initialize(organization)
      @organization = organization
    end

    def call
      accounts = @organization.accounts
                              .includes(:account_balance)
                              .where(account_type: [:asset, :liability, :equity])
                              .where(is_active: true)

      # 1. Fetch Net Income from P&L to roll into current Equity
      pnl_report = ProfitAndLossQuery.new(@organization).call
      net_income = pnl_report[:net_income]

      build_report(accounts, net_income)
    end

    private

    def build_report(accounts, net_income)
      assets, liabilities, equities = [], [], []
      total_assets = BigDecimal("0.0")
      total_liabilities = BigDecimal("0.0")
      total_equity = BigDecimal("0.0")

      accounts.each do |account|
        balance = account.safe_balance
        next if balance.zero?

        data = { name: account.display_name, amount: balance }

        case account.account_type
        when 'asset'
          assets << data
          total_assets += balance
        when 'liability'
          liabilities << data
          total_liabilities += balance
        when 'equity'
          equities << data
          total_equity += balance
        end
      end

      # 2. Add Net Income to Total Equity
      total_equity += net_income
      equities << { name: "Current Year Net Income", amount: net_income }

      # 3. Verify the Core Accounting Equation
      total_liabilities_and_equity = total_liabilities + total_equity
      is_balanced = (total_assets == total_liabilities_and_equity)

      # 4. Programmatic Safety Check (Alert logs if broken)
      unless is_balanced
        Rails.logger.error("URGENT: Balance Sheet mismatch for Org: #{@organization.id}. Assets: #{total_assets}, Liab+Eq: #{total_liabilities_and_equity}")
      end

      {
        assets: assets,
        liabilities: liabilities,
        equities: equities,
        total_assets: total_assets,
        total_liabilities: total_liabilities,
        total_equity: total_equity,
        total_liabilities_and_equity: total_liabilities_and_equity,
        is_balanced: is_balanced
      }
    end
  end
end
