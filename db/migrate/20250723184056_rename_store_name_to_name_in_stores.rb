class RenameStoreNameToNameInStores < ActiveRecord::Migration[8.0]
  def change
    rename_column :stores, :store_name, :name
  end
end
