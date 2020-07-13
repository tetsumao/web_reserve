class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :item_name
      t.integer :stock
      t.text :description
      t.integer :dspo, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :items, :deleted_at
  end
end
