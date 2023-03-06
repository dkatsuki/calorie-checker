class CreateDishArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :dish_articles do |t|
      t.references :dish, foreign_key: true
      t.json :headers
      t.text :body, null: false
      t.timestamps
    end
  end
end
