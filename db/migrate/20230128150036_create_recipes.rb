class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.references :foodstuff, foreign_key: true
      t.references :dish, foreign_key: true
      t.timestamps
    end
  end
end
