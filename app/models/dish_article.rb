class DishArticle < ApplicationRecord
  @@japanese_name = '料理記事'

  def self.japanese_name
    @@japanese_name
  end
end
