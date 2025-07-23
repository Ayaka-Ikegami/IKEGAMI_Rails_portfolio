class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores do |t|
      t.string :store_name
      t.string :place_id, null: false

      t.timestamps
    end
    add_index :stores, :place_id, unique: true
  end
end
