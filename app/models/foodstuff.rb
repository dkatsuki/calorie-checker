class Foodstuff < ApplicationRecord
  # attribute :unit_list, :json, default: {}

  @@japanese_column_names_list = {
    name: '名前',
    calorie: 'カロリー',
    carbohydrate: '炭水化物',
    fat: '脂質',
    protein: 'タンパク質',
    sugar: '糖質',
  }

  def self.japanese_column_names_list
    @@japanese_column_names_list
  end

  # 栄養素は100gあたり
  validates :name, presence: {message: '食材名の入力は必須です。'}
  validates :name, uniqueness: {message: '既にこの食材名は登録されています。'}
  validates :calorie, presence: {message: '100gあたりのカロリーは入力必須です'}
  validates :carbohydrate, presence: {message: '100gあたりの炭水化物は入力必須です'}
  validates :fat, presence: {message: '100gあたりの脂質は入力必須です'}
  validates :protein, presence: {message: '100gあたりのタンパク質は入力必須です'}
  validates :sugar, presence: {message: '100gあたりの糖質は入力必須です'}
end
