class CreateFoodstuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :foodstuffs do |t|
      t.string :name, null: false
      t.string :ruby, null: false
      t.integer :category, null: false, default: 0
      t.boolean :is_pure, null: false, default: true
      t.json  :unit_list, null: false, default: {}
      t.string :main_image_key
      t.float :calorie, null: false
      t.float :carbohydrate, null: false
      t.float :fat, null: false
      t.float :protein, null: false
      t.float :sugar, null: false
      t.timestamps
    end
  end
end
