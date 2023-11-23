# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.example.com"

SitemapGenerator::Sitemap.create do
  # '/articles' を追加する
  add '/', changefreq: 'daily', lastmod: Time.now
  add '/dishes', changefreq: 'daily', lastmod: Time.now

  Dish.where(is_open: true).find_each do |dish|
    add "/dishes/#{dish.id}", lastmod: dish.updated_at
  end

end
