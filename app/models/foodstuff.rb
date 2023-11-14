class Foodstuff < ApplicationRecord
	include ImageAttachment

  has_many :recipes
  has_many :dishes, through: :recipes, source: :dish

  # 栄養素は100gあたり
  validates :name, presence: {message: '食材名の入力は必須です。'}
  validates :name, uniqueness: {message: '既にこの食材名は登録されています。'}
  validates :calorie, presence: {message: '100gあたりのカロリーは入力必須です'}
  validates :carbohydrate, presence: {message: '100gあたりの炭水化物は入力必須です'}
  validates :fat, presence: {message: '100gあたりの脂質は入力必須です'}
  validates :protein, presence: {message: '100gあたりのタンパク質は入力必須です'}
  validates :sugar, presence: {message: '100gあたりの糖質は入力必須です'}

  after_save :create_or_update_dish

  enum category: {
    'その他' => 0,
    '既製品' => 1,
    '穀類' => 2,
    '野菜' => 3,
    '果物' => 4,
    'いも' => 5,
    '甘味' => 6,
    '豆/種' => 7,
    'きのこ' => 8,
    '海藻' => 9,
    '魚介' => 10,
    '肉' => 11,
    '乳製品/卵' => 12,
    '調味料/油/スパイス' => 13,
    '飲料/酒' => 14,
	}, _prefix: true

  @@japanese_name = '食材'
  @@nutrition_name_list = {
    calorie: 'カロリー',
    sugar: '糖質',
    protein: 'タンパク質',
    fat: '脂質',
    carbohydrate: '炭水化物',
  }

  after_initialize do
  end

  def self.nutrition_name_list
    @@nutrition_name_list
  end

  def self.japanese_name
    @@japanese_name
  end

  def self.search(params)
    query = self.all

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

    limit = params[:limit].present? ? params[:limit].to_i : 10000
    query = query.limit(limit)

    if params[:page].present?
      page = params[:page].to_i
      query = query.offset(limit * (page - 1)) if page != 0
    end

    query
  end

  def name=(value)
		self.ruby = value.to_consistent if self.ruby.blank?
		self.write_attribute(:name, value)
	end

  def ruby=(value)
		new_value = value.split(',').map {|word| word.to_consistent}.join(',')
		self.write_attribute(:ruby, new_value)
	end

  def pure?
    self.is_pure
  end

  def get_genre
    self.pure? ? '食材' : '既製品'
  end

  def get_main_unit
    self.unit_list.first.first
  end

  def main_unit
    @main_unit ||= self.get_main_unit
  end

  def get_main_unit_gram
    self.unit_list.first.last
  end

  def main_unit_gram
    @main_unit_gram ||= self.get_main_unit_gram
  end

  def add_unit(unit_name, gram_weight)
    self.unit_list[unit_name] = gram_weight.to_f
  end

  def get_unit_gram(unit_name)
    self.unit_list[unit_name.to_s]
  end

  def remove_unit(unit_name)
    self.unit_list.delete(unit_name)
  end

  def create_or_update_dish
    unit = self.get_main_unit
    dish_attributes = {
      name: self.name,
      genre: self.get_genre,
      unit: unit,
      main_image_key: self.main_image_key
    }
    dish = self.get_association_class(:dishes).find_or_initialize_by(dish_attributes)
    dish.recipes.delete_all
    dish.recipes.build(foodstuff_id: self.id, unit: unit, gram_weight: self.main_unit_gram) # ココ！
    dish.save
  end

  def get_nutrition_by(nutrition_name, gram_or_unit)
    return nil if self.send(nutrition_name).blank?
    nutrition_name = nutrition_name.to_s
    gram = gram_or_unit.is_a?(Float) ? gram_or_unit : self.unit_list[gram_or_unit]
    self.send(nutrition_name) * (gram / 100.0)
  end

  def retouch_image(image_path)
    # image = MiniMagick::Image.open(image_path)
    # image.format('jpeg')
    # image.fuzz(20)
    # image.bordercolor('#000000')
    # image.border('1x1')
    # image.trim
    # image.modulate('110,120,100')
    # image

    ################

    # return unless @tmp_images&.[](:image_key).is_a? MiniMagick::Image
    # image = @tmp_images[:image_key]
    # # image = MiniMagick::Image.open(@tmp_images[:image_key].tempfile.path)
    # width, height = [image[:width] , image[:height]]
    # return if image[:width] > image[:height]
    # # image.crop("#{new_width}x#{new_height}+#{offset_x}+#{offset_y}!")
    # new_width  = (width * 0.94).to_i
    # new_height = (new_width * 0.5).to_i
    # offset_x 	 = ((width - new_width) * 0.5).to_i
    # offset_y	 = (height * 0.13).to_i
    # image.crop("#{new_width}x#{new_height}+#{offset_x}+#{offset_y}!")
  end

  @@nutrition_name_list.keys.each do |nutrition_name|
    define_method("get_#{nutrition_name}_by") do |gram_or_unit|
      self.get_nutrition_by(nutrition_name, gram_or_unit)
    end

    define_method("#{nutrition_name}=") do |amount|
      if amount.present?
        self.write_attribute(nutrition_name, amount.to_i.round(2))
      end
    end
  end
end
