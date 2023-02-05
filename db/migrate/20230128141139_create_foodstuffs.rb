class CreateFoodstuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :foodstuffs do |t|
      t.string :name, null: false
      t.string :is_pure, null: false, default: true
      t.json  :unit_list, null: false, default: {}
      t.string :main_image_key
      t.float :calorie, null: false
      t.float :carbohydrate
      t.float :fat
      t.float :protein
      t.float :sugar
      t.timestamps
    end
  end
end
