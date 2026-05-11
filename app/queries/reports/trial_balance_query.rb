module Reports
  class TrialBalanceQuery
    def initialize(organization)
      @organization = organization
    end

    def call
      # Fetch all accounts with their materialized balances, avoiding N+1 queries
      accounts = @organization.accounts
                              .includes(:account_balance)
                              .where(is_active: true)
                              .order(:code)

      build_report(accounts)
    end

    private

    def build_report(accounts)
      total_debit = BigDecimal("0.0")
      total_credit = BigDecimal("0.0")
      lines = []

      accounts.each do |account|
        balance = account.safe_balance
        next if balance.zero? # Zero balance accounts are traditionally hidden

        debit_val = BigDecimal("0.0")
        credit_val = BigDecimal("0.0")

        # Assign column based on normal balance behavior
        if account.debit_normal?
          debit_val = balance
          total_debit += balance
        else
          credit_val = balance
          total_credit += balance
        end

        lines << {
          code: account.code,
          name: account.name,
          debit: debit_val,
          credit: credit_val
        }
      end

      {
        lines: lines,
        total_debit: total_debit,
        total_credit: total_credit,
        is_balanced: total_debit == total_credit
      }
    end
  end
end
