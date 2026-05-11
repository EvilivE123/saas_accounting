class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      t.references :organization, type: :integer, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      
      t.date :entry_date, null: false
      t.text :description, null: false
      t.boolean :is_locked, null: false, default: false

      t.timestamps
    end
    # Optimize lookups for chronological reporting
    add_index :journal_entries, [:organization_id, :entry_date]
  end
end
