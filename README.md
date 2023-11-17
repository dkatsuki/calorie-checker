# README

## postgres
- 起動
sudo systemctl start postgresql

- psql起動
sudo -u postgres psql

## アセットプリコンパイル
RAILS_ENV=production bin/rails assets:precompile

## nginx
- 起動
  - sudo service nginx start
- 確認
  - ps aux | grep nginx
- 停止
  - sudo service nginx stop

## unicorn
- 起動
  - bundle exec unicorn_rails -c config/unicorn.rb -p 3000 -E production -D
- 確認
  - ps -ef | grep unicorn | grep -v grep
- 停止
  - kill -QUIT pid(tmp/unicorn.pidに記載されてる)
