class Dish < ApplicationRecord
	enum genre: {
		dish: 0, pure_foodstuff: 1, ready_made: 2,
	}

  has_many :recipes
  has_many :food_stuffs, through: :recipes

	@@japanese_name = '料理'

	def self.japanese_name
		@@japanese_name
	end
end
