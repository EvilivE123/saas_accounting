class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :base_currency, null: false, default: "INR"
      t.date :fiscal_year_start

      t.timestamps
    end
  end
end
