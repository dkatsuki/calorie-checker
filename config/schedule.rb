# # # Use this file to easily define all of your cron jobs.
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# git hub repo: http://github.com/javan/whenever

# # # コマンド
# 設定内容にエラーがないか確認
# bundle exec whenever
#
# 設定されているcronを見る
# crontab -l
#
# cronにデータを反映
# bundle exec whenever --update-crontab
#
# cronからデータを削除
# bundle exec whenever --clear-crontab

every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
end
