class GeneralLedgersController < ApplicationController
  def index
    # Fetch all active accounts with their pre-calculated balances to avoid N+1 queries
    @accounts = Current.organization.accounts
                       .includes(:account_balance)
                       .where(is_active: true)
                       .order(:code)
  end

  def show
    @account = Current.organization.accounts.find(params[:id])
    
    # We will utilize a custom query method (defined in Sub-Doc 2) to fetch 
    # the items with a PostgreSQL window function for the running balance.
    @ledger_items = @account.chronological_ledger_entries
  end
end