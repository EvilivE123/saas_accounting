class CreateJournalItems < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_items, id: :uuid do |t|
      t.references :journal_entry, type: :integer, null: false, foreign_key: true
      t.references :account, type: :uuid, null: false, foreign_key: true
      
      # Strict Financial Decimals (Precision 15, Scale 2)
      t.decimal :debit, precision: 15, scale: 2, default: 0.0, null: false
      t.decimal :credit, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
