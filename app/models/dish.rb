class Dish < ApplicationRecord
	attribute :unit, :string, default: '1人前'

	enum genre: {
		"料理": 0, "食材": 1, "既製品": 2,
	}

  has_many :recipes
  has_many :foodstuffs, through: :recipes
	before_validation :set_data_from_recipes

	@@japanese_name = '料理'

	def self.japanese_name
		@@japanese_name
	end

  def self.nutrition_name_list
    self.get_association_class(:foodstuffs).nutrition_name_list
  end

	def self.search(params)
		query = self.limit(params[:limit] || 100)

		if params[:name].present?
			query = query.where('name LIKE ?', "%#{sanitize_sql_like(params[:name].to_s)}%")
		end

		sort_options = []

		if params[:sort].is_a? Array
			sort_options = params[:sort]
		elsif params[:sort]&.[](:key).present? && params[:sort]&.[](:order).present?
			sort_options = [params[:sort]]
		end

		sort_options << {key: :id, order: :asc} if sort_options.present?

		sort_options.each do |sort_option|
			key = sort_option[:key].to_sym
			order = sort_option[:order].to_sym
			query = query.order(key => order)
		end

		query
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

	def calorie
		self.read_attribute(:calorie).round(1)
	end

	def image_source
		self.main_image_key
	end
end
