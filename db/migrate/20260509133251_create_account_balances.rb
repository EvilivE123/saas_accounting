class CreateAccountBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :account_balances, id: :uuid do |t|
      t.references :organization, type: :integer, null: false, foreign_key: true
      t.references :account, type: :uuid, null: false, foreign_key: true
      
      # Strict Financial Decimals (Precision 15, Scale 2)
      t.decimal :current_balance, precision: 15, scale: 2, default: 0.0, null: false
      t.datetime :last_entry_at

      t.timestamps
    end

    # Crucial Index: Ensure one balance record per account, optimized for tenant lookups
    add_index :account_balances, [:organization_id, :account_id], unique: true
  end
end
