class CreateDishes < ActiveRecord::Migration[7.0]
  def change
    create_table :dishes do |t|
      t.string :name, null: false
      t.string :ruby, null: false
      t.integer :genre, null: false, default: 0
      t.string :main_image_key
      t.string :unit, null: false
      t.float :calorie, null: false
      t.float :carbohydrate, null: false
      t.float :fat, null: false
      t.float :protein, null: false
      t.float :sugar, null: false
      t.boolean :is_open, null: false, default: false
      t.timestamps
    end
  end
end
