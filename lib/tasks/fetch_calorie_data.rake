require Rails.root.to_s + '/lib/tasks/modules/calorie_data_fetcher.rb'

namespace :fetch_calorie_data do
  desc "htmlを取得"
  task :crawl => :environment do
    fetcher = CalorieDataFetcher.new
    fetcher.fetch_htmls
  end

  desc "スクレイピング"
  task :scrape => :environment do
    fetcher = CalorieDataFetcher.new
    fetcher.scrape_htmls
  end
end