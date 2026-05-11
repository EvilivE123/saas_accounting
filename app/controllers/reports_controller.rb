class ReportsController < ApplicationController
  # Ensures all actions restrict data to the current tenant (Phase 1 logic)
  
  def trial_balance
    @report = Reports::TrialBalanceQuery.new(Current.organization).call
  end

  def profit_and_loss
    @report = Reports::ProfitAndLossQuery.new(Current.organization).call
  end

  def balance_sheet
    @report = Reports::BalanceSheetQuery.new(Current.organization).call
  end
end
