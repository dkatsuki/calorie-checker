class Dish < ApplicationRecord
	include ImageAttachment

	attribute :unit, :string, default: '1人前'

	enum genre: {
		"料理": 0, "食材": 1, "既製品": 2,
	}, _prefix: true

  has_many :recipes, autosave: true
  has_many :foodstuffs, through: :recipes
	accepts_nested_attributes_for :recipes
	before_validation :set_data_from_recipes

	@@japanese_name = '料理'

	def self.japanese_name
		@@japanese_name
	end

  def self.nutrition_name_list
    self.get_association_class(:foodstuffs).nutrition_name_list
  end

	def self.search(params)
		query = self.all

		if params[:name].present?
			query = query.where('name LIKE ?', "%#{sanitize_sql_like(params[:name].to_s)}%")
		end

		if params[:genre].present?
			query = query.where(genre: params[:genre])
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

		limit = params[:limit].present? ? params[:limit].to_i : 100
		query = self.limit(limit)

		if params[:page].present?
			page = params[:page].to_i
			query = query.offset(limit * (page - 1)) if page != 0
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
			next if self.send(attr_name).present?
			## まだdish自身がsaveされてなくて直接foodstuffsは呼べないのでrecipes経由
			sum = self.recipes.map do |recipe|
				recipe.foodstuff.get_nutrition_by(attr_name, (recipe.gram_weight || recipe.unit))
			end.sum
			self.send("#{attr_name}=", sum)
		end
	end

	def name=(value)
		self.ruby = value.to_consistent if self.ruby.blank?
		self.write_attribute(:name, value)
	end

	def ruby=(value)
		new_value = value.split(',').map {|word| word.to_consistent}.join(',')
		self.write_attribute(:ruby, new_value)
	end

	def pure_foodstuff?
		self.genre == '食材'
	end

	def pure_dish?
		self.genre == '料理'
	end

	def article_title
		"#{self.name}のカロリーと糖質は？栄養や美容効果、レシピなどを紹介！"
	end

	self.nutrition_name_list.keys.each do |nutrition_name|
    # define_method("get_#{nutrition_name}_by") do |gram_or_unit|
    #   self.get_nutrition_by(nutrition_name, gram_or_unit)
    # end

    define_method("#{nutrition_name}=") do |amount|
			if amount.present?
				self.write_attribute(nutrition_name, amount.to_i.round(2))
			end
    end
  end
end
