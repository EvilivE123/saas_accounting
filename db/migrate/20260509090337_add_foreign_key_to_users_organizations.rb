class AddForeignKeyToUsersOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :users, :organizations, column: :organization_id
    
    # Enforce non-nullability at the DB level for strict multi-tenancy
    change_column_null :users, :organization_id, false    
  end
end
