class Foodstuff < ApplicationRecord
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
    '調味料/油' => 13,
    '飲料/酒' => 14,
	}

  @@japanese_name = '食材'
  @@nutrition_name_list = {
    calorie: 'カロリー',
    sugar: '糖質',
    protein: 'タンパク質',
    fat: '脂質',
    carbohydrate: '炭水化物',
  }

  after_initialize do
    self.unit_list.each do |k,v|
      self.unit_list[k] = v.to_i
    end
  end

  def self.nutrition_name_list
    @@nutrition_name_list
  end

  def self.japanese_name
    @@japanese_name
  end

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

  def pure?
    self.is_pure
  end

  def get_genre
    self.pure? ? '食材' : '既製品'
  end

  def get_main_unit
    self.unit_list.first.first
  end

  def create_or_update_dish
    unit = self.get_main_unit
    dish_attributes = {
      name: self.name,
      genre: self.get_genre,
      unit: unit
    }
    dish = self.get_association_class(:dishes).find_or_initialize_by(dish_attributes)
    dish.recipes.build(foodstuff_id: self.id, unit: unit)
    dish.save
  end

  def get_nutrition_by(nutrition_name, gram_or_unit)
    nutrition_name = nutrition_name.to_s
    gram = gram_or_unit.is_a?(Float) ? gram_or_unit : self.unit_list[gram_or_unit]
    self.send(nutrition_name) * (gram / 100.0)
  end

  def get_calorie_by(gram_or_unit)
    self.get_nutrition_by(:calorie, gram_or_unit)
  end

  def get_carbohydrate_by(gram_or_unit)
    self.get_nutrition_by(:carbohydrate, gram_or_unit)
  end

  def get_fat_by(gram_or_unit)
    self.get_nutrition_by(:fat, gram_or_unit)
  end

  def get_protein_by(gram_or_unit)
    self.get_nutrition_by(:protein, gram_or_unit)
  end

  def get_sugar_by(gram_or_unit)
    self.get_nutrition_by(:sugar, gram_or_unit)
  end
end
