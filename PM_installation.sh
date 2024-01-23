#!/bin/bash
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql
sudo apt install git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev build-essential -y
wget https://www.redmine.org/releases/redmine-5.1.1.tar.gz
read -p 'Enter you database password :' password
echo "CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD '$password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;" > postgresql.sql
sudo -i -u postgures psql < postgresql.sql
tar -xvf redmine-5.1.1.tar.gz
mv redmine-5.1.1 redmine
production_config="
production:
  adapter: postgresql
  database: redmine
  host: 127.0.0.1
  username: postgres
  password: \"$password\"
  encoding: utf8
  schema_search_path: 'public'
"
echo "$production_config" > redmine/config/database.yml
echo "Database configuration file created."
sudo apt install ruby-rubygems -y
sudo apt-get install libcurl4-openssl-dev -y
gem install bundler
sudo apt install ruby-railties -y
sudo apt-get install libpq-dev -y
sudo apt install ruby-bundler -y
sudo apt-get install ruby-dev -y
cd redmine
bundle config set --local without 'development test'
bundle install
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data
passenger-install-nginx-module
