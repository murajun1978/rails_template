require 'bundler'

@template_url = 'https://raw.github.com/murajun1978/rails_template/master/'

gem 'everywhere'

gem_group :development, :test do 
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'database_rewinder'

  gem 'rubocop'
  gem 'brakeman'

  gem 'pry-rails'
  gem 'pry-coolline'
  gem 'pry-debugger'
  gem 'pry-doc'

  gem 'awesome_print'
  gem 'hirb'
  gem 'hirb-unicode'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'table_print'
  
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
  gem 'guard-rspec'
end

gem_group :test do 
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'launchy'
  gem 'poltergeist'
  gem 'turnip'
end

Bundler.with_clean_env do 
  run 'bundle install'
end

run 'bundle exec rails g rspec:install'
run 'bundle exec guard init rspec'

# remove files
%w(
  config/initializers/secret_token.rb
).each do |file|
  remove_file file
end

# secret_token.rb
get @template_url + 'secret_token.rb', 'config/initializers/secret_token.rb'

# spec_helper
inject_into_file 'spec/spec_helper.rb', after: 'RSpec.configure do |config|' do 
<<-DATABASE_REWINDER

  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end

DATABASE_REWINDER
end

append_file '.gitignore' do 
<<-GIT

/vendor/bundler
/coverage
/.secret
.DS_Store
GIT
end
