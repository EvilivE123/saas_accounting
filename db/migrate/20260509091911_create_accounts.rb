class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :uuid do |t|
      # Multi-Tenancy Link
      t.references :organization, type: :integer, null: false, foreign_key: true
      
      # Self-Referential Hierarchy Link (Parent/Child Accounts)
      t.references :parent, type: :uuid, null: true, foreign_key: { to_table: :accounts }

      # Core Account Attributes
      t.string :name, null: false
      t.string :code, null: false
      t.string :account_type, null: false # Will map to an Enum in the model
      t.text :description
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    # Strict Database Constraint:
    # An account code (e.g., '1000') must be unique WITHIN an organization, 
    # but multiple organizations can have the same code.
    add_index :accounts, [:organization_id, :code], unique: true
  end
end
