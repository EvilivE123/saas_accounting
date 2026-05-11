class Account < ApplicationRecord
  # 1. Multi-Tenancy Scoping (from Phase 1.3)
  include Tenantable
  
  belongs_to :organization

  # 2. Self-Referential Hierarchy
  belongs_to :parent, class_name: 'Account', optional: true
  has_many :sub_accounts, class_name: 'Account', foreign_key: 'parent_id', dependent: :restrict_with_error
  has_one :account_balance, dependent: :destroy

  # 3. The 5 Accounting Pillars Enum
  enum :account_type, {
    asset: 'asset',
    liability: 'liability',
    equity: 'equity',
    revenue: 'revenue',
    expense: 'expense'
  }

  # 4. Strict Validations
  validates :name, presence: true
  validates :account_type, presence: true
  validates :code, presence: true, uniqueness: { 
    scope: :organization_id, 
    message: "must be unique within your organization" 
  }
  has_many :journal_items, dependent: :restrict_with_error
  # Ensure an account cannot be its own parent
  validate :parent_cannot_be_self
  before_destroy :ensure_no_financial_activity
  # Lifecycle Callback
  after_create :initialize_balance_record

  # Helper method to safely fetch the balance without nil errors
  def safe_balance
    account_balance&.current_balance || BigDecimal("0.0")
  end

  # ==========================================
  # Accounting Logic Helpers
  # ==========================================

  # Determines if an increase in this account is recorded as a Debit.
  # Assets and Expenses increase with Debits.
  def debit_normal?
    asset? || expense?
  end

  # Determines if an increase in this account is recorded as a Credit.
  # Liabilities, Equity, and Revenue increase with Credits.
  def credit_normal?
    liability? || equity? || revenue?
  end

  # ==========================================
  # Hierarchy Traversal Helpers
  # ==========================================

  # Is this a top-level account?
  def root?
    parent_id.nil?
  end

  # Is this a transactional account with no sub-accounts?
  def leaf?
    sub_accounts.empty?
  end

  # Retrieves the full lineage formatted for UI display
  # e.g., "Current Assets > Bank Accounts > Chase Checking"
  def hierarchy_path
    if root?
      name
    else
      "#{parent.hierarchy_path} > #{name}"
    end
  end
  
  # Displays the code and name together
  def display_name
    "#{code} - #{name}"
  end

  def chronological_ledger_entries
    JournalItem.joins(:journal_entry, :account)
               .where(account_id: self.id)
               .select(
                 "journal_items.*",
                 "journal_entries.entry_date",
                 "journal_entries.description as entry_description",
                 "journal_entries.id as entry_id",
                 "SUM(
                    CASE
                      WHEN accounts.account_type IN ('asset', 'expense') 
                        THEN journal_items.debit - journal_items.credit
                      ELSE 
                        journal_items.credit - journal_items.debit
                    END
                  ) OVER (
                    ORDER BY journal_entries.entry_date ASC, journal_entries.created_at ASC
                  ) AS running_balance"
               )
               .order("journal_entries.entry_date ASC, journal_entries.created_at ASC")
  end  

  private

  # Automatically creates a 0.00 balance record when a new account is born
  def initialize_balance_record
    create_account_balance!(
      organization_id: organization_id,
      current_balance: 0.0
    )
  end  

  def parent_cannot_be_self
    if parent_id.present? && parent_id == id
      errors.add(:parent_id, "cannot be the same as the account itself")
    end
  end

  def ensure_no_financial_activity
    # 1. Check if the account has any journal items tied to it
    if journal_items.exists?
      errors.add(:base, "Cannot delete an account that has historical transaction data. Deactivate it instead.")
      throw(:abort)
    end

    # 2. Check if the account balance is non-zero
    if safe_balance != 0
      errors.add(:base, "Cannot delete an account with a non-zero balance.")
      throw(:abort)
    end

    # 3. Check if it is a parent to other accounts
    if sub_accounts.exists?
      errors.add(:base, "Cannot delete an account that contains sub-accounts. Reassign them first.")
      throw(:abort)
    end
  end
end
