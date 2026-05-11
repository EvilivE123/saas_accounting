class JournalEntriesController < ApplicationController
  def index
    @entries = Current.organization.journal_entries.order(entry_date: :desc).limit(50)
  end

  def new
    @entry = Current.organization.journal_entries.build
    @entry.entry_date = Date.today
    
    # Pre-build minimum required double-entry lines
    2.times { @entry.journal_items.build }
    
    # Load active accounts for the dropdowns
    @accounts = Current.organization.accounts.where(is_active: true).order(:code)
  end

  def show
    # Ensures tenant scoping via Current.organization
    @entry = Current.organization.journal_entries.includes(journal_items: :account).find(params[:id])
  end  

  def create
    @entry = Current.organization.journal_entries.build(journal_entry_params)
    @entry.user = current_user

    # Wrap the entire process in an atomic database transaction
    ActiveRecord::Base.transaction do
      if @entry.save
        
        # ---------------------------------------------------------
        # FIRE THE POSTING SERVICE
        # Instantly updates the materialized account_balances table
        # ---------------------------------------------------------
        Ledger::PostingService.new(@entry).call
        
        # Handle Successful Response
        respond_to do |format|
          format.html { redirect_to journal_entries_path, notice: 'Journal Entry posted successfully.' }
          format.json { render_json_success('Entry posted successfully.', { id: @entry.id, redirect_url: journal_entries_path }) }
        end
      else
        # Trigger an automatic transaction rollback if validations fail
        raise ActiveRecord::Rollback
      end
    end
    
    # Handle Failure Response (Executes if the transaction was rolled back)
    unless @entry.persisted?
      respond_to do |format|
        format.html do
          @accounts = Current.organization.accounts.where(is_active: true).order(:code)
          render :new, status: :unprocessable_entity
        end
        format.json { render_json_error(@entry.errors.full_messages) }
      end
    end
  end


  private

  def journal_entry_params
    params.require(:journal_entry).permit(
      :entry_date, :description,
      journal_items_attributes: [:id, :account_id, :debit, :credit, :_destroy]
    )
  end
end
