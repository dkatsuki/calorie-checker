class DishArticle < ApplicationRecord
	include MarkDownAttachment

  @@japanese_name = '料理記事'

  belongs_to :dish, class_name: "Dish"

  def self.japanese_name
    @@japanese_name
  end
end
