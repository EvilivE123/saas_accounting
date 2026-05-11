module Ledger
  class PostingService
    def initialize(journal_entry)
      @journal_entry = journal_entry
    end

    def call
      # Ensure this executes within the broader database transaction
      ActiveRecord::Base.transaction do
        @journal_entry.journal_items.each do |item|
          
          # Fetch the related balance record
          balance_record = item.account.account_balance
          
          # CRITICAL: Pessimistic Database Lock
          # Prevents another concurrent transaction from modifying this exact 
          # balance record until this transaction commits or rolls back.
          balance_record.lock!

          # Calculate the mathematical impact (+ or -)
          impact = calculate_impact(item)

          # Apply the impact and update the timestamp
          balance_record.current_balance += impact
          balance_record.last_entry_at = Time.current
          
          # Persist the updated snapshot to PostgreSQL
          balance_record.save!
        end
      end
    end

    private

    # Determines how to mathematically apply the debit/credit 
    # based on the account's normal balance behavior.
    def calculate_impact(item)
      account = item.account
      
      if account.debit_normal?
        # Assets & Expenses: Debits increase the balance, Credits decrease it
        item.debit - item.credit
      else
        # Liabilities, Equity & Revenue: Credits increase the balance, Debits decrease it
        item.credit - item.debit
      end
    end
  end
end