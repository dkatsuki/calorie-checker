module DishesHelper
  def unit_with_gram_text(dish)
    return dish.unit if dish.pure_dish? || (dish.foodstuffs.length > 1)
    gram_weight = dish.foodstuffs.first.unit_list[dish.unit]
    return dish.unit if gram_weight.blank?
    "#{dish.unit}(#{gram_weight}g)"
  end
end
