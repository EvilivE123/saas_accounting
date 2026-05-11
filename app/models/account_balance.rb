class AccountBalance < ApplicationRecord
  # 1. Multi-Tenancy Scoping (From Phase 1)
  include Tenantable

  # 2. Associations
  belongs_to :organization
  belongs_to :account

  # 3. Validations
  validates :current_balance, numericality: true
  
  # Note: current_balance CAN be negative. For example, if a Bank Account (Asset)
  # becomes overdrawn, it will carry a negative balance representing a liability state.
  
  # 4. Helper Methods
  # Returns the balance formatted safely as a float for API/JSON consumption
  def formatted_balance
    current_balance.to_f
  end

end
