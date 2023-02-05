class Dish < ApplicationRecord
	enum type: {
		dish: 0, pure_foodstuff: 1, ready_made: 2,
	}

  has_many :recipes
  has_many :food_stuffs, through: :recipesre
end
