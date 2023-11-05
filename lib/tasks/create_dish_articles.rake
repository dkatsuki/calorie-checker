namespace :dish_articles do
  desc "サンプルデータを表示"
  task :create => :environment do
    dishes = Dish.eager_load(:dish_articles).where(dish_articles: {id: nil})

    dishes.find_each do |dish|
      dish.build_article
      dish.article.body = dish.article.generate_article
      dish.article.save
    end
  end
end