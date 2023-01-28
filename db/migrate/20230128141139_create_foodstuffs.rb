class CreateFoodstuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :foodstuffs do |t|
      t.string :name, null: false
      t.jsonb  :unit_list, null: false, default: '{}'
      t.string :main_image_key
      t.integer :calorie_per_100_grams, null: false
      t.integer :carbohydrate
      t.integer :fat
      t.integer :protein
      t.integer :sugar
      t.timestamps
    end
  end
end
