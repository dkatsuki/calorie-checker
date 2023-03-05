class DishArticle < ApplicationRecord
  @@japanese_name = '料理記事'

  belongs_to :dish, class_name: "DishArticle"

  def self.japanese_name
    @@japanese_name
  end
end
