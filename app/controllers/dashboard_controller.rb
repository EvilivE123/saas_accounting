class DashboardController < ApplicationController
  def index
    # 1. Date Filtering Logic
    set_date_range

    # 2. Base Queries scoped to tenant and date range
    base_items = JournalItem.joins(:journal_entry, :account)
                            .where(journal_entries: { organization_id: Current.organization.id })
                            .where(journal_entries: { entry_date: @start_date..@end_date })

    # ==========================================
    # WIDGET 1, 2, 3: KPI Cards (Assets, Liabilities, Net Income)
    # ==========================================
    @total_assets = calculate_balance(base_items, 'asset')
    @total_liabilities = calculate_balance(base_items, 'liability')
    
    revenue = calculate_balance(base_items, 'revenue')
    expenses = calculate_balance(base_items, 'expense')
    @net_income = revenue - expenses

    # ==========================================
    # WIDGET 4: Revenue vs Expenses (Bar Chart Data)
    # ==========================================
    @rev_exp_data = {
      labels: ['Revenue', 'Expenses'],
      datasets: [{ label: 'Amount', data: [revenue.to_f, expenses.to_f], backgroundColor: ['#198754', '#dc3545'] }]
    }

    # ==========================================
    # WIDGET 5: Asset Distribution (Doughnut Chart Data)
    # ==========================================
    asset_breakdown = base_items.where(accounts: { account_type: 'asset' })
                                .group('accounts.name')
                                .sum('journal_items.debit - journal_items.credit')
    
    @asset_dist_data = {
      labels: asset_breakdown.keys,
      datasets: [{ data: asset_breakdown.values.map(&:to_f), backgroundColor: ['#0d6efd', '#6610f2', '#6f42c1', '#d63384', '#fd7e14'] }]
    }

    # ==========================================
    # WIDGET 6: Cash Flow Trend (Line Chart Data)
    # ==========================================
    cash_trend = base_items.where(accounts: { account_type: 'asset' })
                           .where("accounts.name ILIKE '%cash%' OR accounts.name ILIKE '%bank%'")
                           .group("DATE_TRUNC('month', journal_entries.entry_date)")
                           .sum('journal_items.debit - journal_items.credit')
                           
    @cash_trend_data = {
      labels: cash_trend.keys.map { |d| d.strftime("%b %Y") },
      datasets: [{ label: 'Cash/Bank Balance', data: cash_trend.values.map(&:to_f), borderColor: '#0dcaf0', tension: 0.1 }]
    }

    # ==========================================
    # WIDGET 7: Recent Transactions List
    # ==========================================
    @recent_transactions = Current.organization.journal_entries
                                  .where(entry_date: @start_date..@end_date)
                                  .order(entry_date: :desc, created_at: :desc)
                                  .limit(5)
  end

  private

  def set_date_range
    @filter_type = params[:filter] || 'this_year'
    
    today = Date.current
    case @filter_type
    when 'this_month'
      @start_date = today.beginning_of_month
      @end_date = today.end_of_month
    when 'last_month'
      @start_date = 1.month.ago.beginning_of_month
      @end_date = 1.month.ago.end_of_month
    when 'this_year'
      @start_date = today.beginning_of_year
      @end_date = today.end_of_year
    when 'custom'
      @start_date = Date.parse(params[:start_date]) rescue today.beginning_of_year
      @end_date = Date.parse(params[:end_date]) rescue today.end_of_year
    else
      @start_date = today.beginning_of_year
      @end_date = today.end_of_year
    end
  end

  def calculate_balance(items, type)
    if %w[asset expense].include?(type)
      items.where(accounts: { account_type: type }).sum('journal_items.debit - journal_items.credit')
    else
      items.where(accounts: { account_type: type }).sum('journal_items.credit - journal_items.debit')
    end
  end
end
