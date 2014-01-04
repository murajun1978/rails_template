require 'bundler'

@template_url = 'https://raw.github.com/murajun1978/rails_template/master/'

gem 'pg', group: :production
gem 'bcrypt-ruby'
gem 'everywhere'
gem 'bcrypt-ruby'

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
  gem 'guard-rspec', require: false
end

gem_group :test do 
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'launchy'
  gem 'poltergeist'
  gem 'turnip'
  gem 'fuubar'
end

Bundler.with_clean_env do 
  inject_into_file 'Gemfile', after: "gem 'sqlite3'" do 
  <<-GEMFILE
  , group: [:development, :test]
  GEMFILE
  end

  run 'bundle install --without production'
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
append_file 'config/initializers/secret_token.rb' do 
  <<-TOKEN
  ApplicationClassName::Application.config.secret_key_base = secure_token
  TOKEN
end

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
