class Recipe < ApplicationRecord
  @@japanese_name =  "レシピ"

  def self.japanese_name
    @@japanese_name
  end

  belongs_to :dish
end
