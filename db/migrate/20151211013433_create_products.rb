class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price, precision: 8, scale: 4, default: 0
      t.text :description
      t.string :type
      t.integer :quantity, default: 0
      t.float :discount, default: 1

      t.timestamps null: false
    end
  end
end
