class Dish < ApplicationRecord
	attribute :unit, :string, default: '1人前'

	enum genre: {
		dish: 0, pure_foodstuff: 1, ready_made: 2,
	}

  has_many :recipes
  has_many :foodstuffs, through: :recipes
	before_validation :set_data_from_recipes

	@@japanese_name = '料理'

	def self.japanese_name
		@@japanese_name
	end

	def self.search(params)
		self.where('name LIKE ?', "%#{sanitize_sql_like(params[:name].to_s)}%")
	end

	def set_data_from_recipes
		[
			:calorie,
			:carbohydrate,
			:fat,
			:protein,
			:sugar,
		].each do |attr_name|
			## まだdish自身がsaveされてなくて直接foodstuffsは呼べないのでrecipes経由
			sum = self.recipes.map do |recipe|
				recipe.foodstuff.get_nutrition_by(attr_name, (recipe.gram_weight || recipe.unit))
			end.sum
			self.send("#{attr_name}=", sum)
		end
	end

	def image_source
		self.main_image_key
	end
end
