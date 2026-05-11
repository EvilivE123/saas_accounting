class JournalItem < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :account

  validates :account_id, presence: true
  
  # Ensure numbers are not negative
  validates :debit, numericality: { greater_than_or_equal_to: 0 }
  validates :credit, numericality: { greater_than_or_equal_to: 0 }
  
  # Custom validation: A line must have value
  validate :must_have_debit_or_credit

  before_update :prevent_modification_if_locked
  before_destroy :prevent_modification_if_locked

  before_validation :check_credit_and_debit

  def check_credit_and_debit
    self.credit = 0.0 if self.credit.blank?
    self.debit = 0.0 if self.debit.blank?
  end  

  private

  def must_have_debit_or_credit
    if debit.zero? && credit.zero?
      errors.add(:base, "Line item must have either a debit or a credit amount.")
    end
    
    if debit > 0 && credit > 0
      errors.add(:base, "A single line item cannot contain both a debit and a credit. Use separate lines.")
    end
  end

  def prevent_modification_if_locked
    if journal_entry&.is_locked?
      errors.add(:base, "Cannot modify a line item belonging to a locked journal entry.")
      throw(:abort)
    end
  end  
end
