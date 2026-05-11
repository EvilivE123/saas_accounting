module Queries
  class GeneralLedgerQuery
    # We pass the specific Account we want to view the ledger for
    def self.call(account)
      # Define the mathematical logic based on the account's normal balance
      # Assets/Expenses increase with debits. Liabilities/Equity/Revenue increase with credits.
      balance_calculation = if account.debit_normal?
                              "journal_items.debit - journal_items.credit"
                            else
                              "journal_items.credit - journal_items.debit"
                            end

      # The PostgreSQL Window Function:
      # SUM() OVER (ORDER BY date) creates a cumulative running total row by row.
      window_function = "SUM(#{balance_calculation}) OVER (
        PARTITION BY journal_items.account_id 
        ORDER BY journal_entries.entry_date ASC, journal_entries.created_at ASC
      ) AS running_balance"

      # Execute the Active Record query, returning JournalItem objects 
      # enriched with the dynamic 'running_balance' attribute.
      account.journal_items
             .joins(:journal_entry)
             .select('journal_items.*')
             .select('journal_entries.entry_date, journal_entries.description, journal_entries.id AS je_id')
             .select(window_function)
             .order('journal_entries.entry_date ASC, journal_entries.created_at ASC')
    end
  end
end