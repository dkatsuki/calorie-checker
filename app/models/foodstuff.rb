class Foodstuff < ApplicationRecord
  validates :name, presence: {message: '食材名の入力は必須です。'}
end
