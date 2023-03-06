class DishArticle < ApplicationRecord
	include MarkDownAttachment

  @@japanese_name = '料理記事'

  belongs_to :dish, class_name: "Dish"

  def self.japanese_name
    @@japanese_name
  end

  def body=(value)
    doc = self.class.giko_giko(self.class.to_html(value))
    self.headers = doc.css('h1, h2, h3').map {|e| {tagName: e.name, text: e.text} }
    super(value)
  end
end
