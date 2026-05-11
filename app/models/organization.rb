class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :journal_entries, dependent: :destroy

  validates :name, presence: true
  validates :base_currency, presence: true, length: { is: 3 } # ISO Currency Code length

  # Standard ISO to Symbol Mapping
  CURRENCY_SYMBOLS = {
    'USD' => '$',
    'EUR' => '€',
    'GBP' => '£',
    'INR' => '₹',
    'JPY' => '¥',
    'AUD' => 'A$',
    'CAD' => 'C$'
  }.freeze

  # Returns the symbol for the active base_currency.
  # If a currency isn't in the hash, it gracefully falls back to printing the 3-letter ISO code.
  def currency_symbol
    CURRENCY_SYMBOLS[base_currency.to_s.upcase] || base_currency.to_s.upcase
  end  
end
