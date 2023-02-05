class CreateDishes < ActiveRecord::Migration[7.0]
  def change
    create_table :dishes do |t|
      t.string :name, null: false
      t.integer :genre, null: false, default: 0
      t.timestamps
    end
  end
end
