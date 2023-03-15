class PagesController < ApplicationController
  def top
    @model = Dish
    @records = @model.search({limit: 6})
    @basal_metabolic_rate_list = get_basal_metabolic_rate_list
  end

  private
    def get_basal_metabolic_rate_list
      [
        # ['年齢', '参照体重(女)', '基礎代謝量(女)', '参照体重(男)', '基礎代謝量(男)'],
        ['〜2歳', 11.0, 660, 11.5, 700],
        ['〜5歳', 16.1, 840, 16.5, 900],
        ['〜7歳', 21.9, 920, 22.2, 980],
        ['〜9歳', 27.4, 1050, 28.0, 1140],
        ['〜11歳', 36.3, 1260, 35.6, 1330],
        ['〜14歳', 47.5, 1410, 49.0, 1520],
        ['〜17歳', 51.9, 1310, 59.7, 1610],
        ['〜29歳', 50.0, 1110, 63.2, 1520],
        ['〜49歳', 53.1, 1150, 68.5, 1530],
        ['〜69歳', 53.0, 1100, 65.3, 1400],
        ['70歳以上', 49.5, 1020, 60.0, 1290],
      ]
    end
end
