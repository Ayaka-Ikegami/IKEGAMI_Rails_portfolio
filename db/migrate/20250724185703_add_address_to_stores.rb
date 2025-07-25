class AddAddressToStores < ActiveRecord::Migration[8.0]
  def change
    add_column :stores, :address, :string
  end
end
