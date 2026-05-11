class JournalEntry < ApplicationRecord
  # Multi-Tenancy Scoping (From Phase 1)
  include Tenantable

  belongs_to :organization
  belongs_to :user
  
  has_many :journal_items, inverse_of: :journal_entry, dependent: :destroy

  # Allows the UI to send an array of items and process them atomically
  accepts_nested_attributes_for :journal_items, allow_destroy: true, reject_if: :all_blank

  # Basic Validations
  validates :entry_date, presence: true
  validates :description, presence: true

  # Core Accounting Validation
  validate :must_be_balanced

  # Immutability Callbacks
  before_update :prevent_modification_if_locked
  before_destroy :prevent_modification_if_locked

  private

  def prevent_modification_if_locked
    if is_locked_was || is_locked?
      # Allow status changes to locked (closing a period), but prevent edits after.
      unless changed == ["is_locked"] && is_locked?
        errors.add(:base, "This journal entry is locked and cannot be modified or deleted. It belongs to a closed fiscal period.")
        throw(:abort) # Halts the Active Record callback chain and rolls back
      end
    end
  end  

  def must_be_balanced
    # 1. Reject items marked for destruction by the dynamic UI
    active_items = journal_items.reject(&:marked_for_destruction?)

    # 2. Require at least two lines for a valid double-entry
    if active_items.length < 2
      errors.add(:base, "A journal entry must have at least two line items.")
      return
    end

    # 3. Sum the decimals in Ruby memory using BigDecimal
    total_debits = active_items.sum { |item| BigDecimal(item.debit.to_s) }
    total_credits = active_items.sum { |item| BigDecimal(item.credit.to_s) }

    # 4. Check for equality
    if total_debits != total_credits
      errors.add(:base, "Transaction is not balanced. Total Debits (##{total_debits}) must equal Total Credits (##{total_credits}).")
    end

    # 5. Prevent zero-value transactions
    if total_debits.zero? && total_credits.zero?
      errors.add(:base, "Journal entry cannot have a total value of zero.")
    end
  end
end