class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## SaaS Specific Fields
      t.integer :organization_id, null: true # Nullable temporarily until Phase 1.3
      t.integer :role, null: false, default: 3 # Default to viewer (least privilege)

      ## Recoverable, Rememberable, etc... (keep standard devise fields)
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :organization_id
  end
end
