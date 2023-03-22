class DishArticle < ApplicationRecord
	include MarkDownAttachment

  @@japanese_name = '料理記事'

  belongs_to :dish, class_name: "Dish"
  validate :no_h1_heading, if: :including_h1_heading?

  def self.japanese_name
    @@japanese_name
  end

  def body=(value)
    doc = self.class.giko_giko(self.class.to_html(value))
    self.headers = doc.css('h2, h3').map {|e| {tagName: e.name, text: e.text} }
    super(value)
  end

  def no_h1_heading
    errors.add(:body, "h1タグを含めることはできません。")
  end

  def including_h1_heading?
    rows = self.body.lines
    rows.each do |row|
      return true if row =~ /^#\s/
    end
    false
  end
end
