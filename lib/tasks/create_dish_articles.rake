namespace :dish_articles do
  desc "サンプルデータを表示"
  task :create => :environment do
    dishes = Dish.where(is_open: false)

    dishes.find_each do |dish|
      dish.build_article
      dish.article.body = dish.article.generate_article
      dish.is_open = true
      base64_image = dish.generate_image
      image_data = Base64.decode64(base64_image)
      path = "tmp/#{dish.id}.png"
      File.open(path, 'wb') do |f|
        f.write(image_data)
      end
      dish.set_image_file_as_action_dispatch_to_image_key(path)
      dish.save
      dish.article.save
    end
  end
end
