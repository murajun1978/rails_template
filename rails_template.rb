require 'bundler'

@template_url = 'https://raw.github.com/murajun1978/rails_template/master/'

gem 'bootstrap-sass'
gem 'pg', group: :production
gem 'bcrypt-ruby'
gem 'everywhere'
gem 'bcrypt-ruby'
gem 'settingslogic'
gem 'quiet_assets', group: :development

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
  
  gem 'rack-mini-profiler'
  gem 'xray-rails' 

  gem 'mail_view', '~> 1.0.3'

  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'pry-rescue'
  gem 'pry-stack_explorer'
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
run 'bundle exec spring binstub --all'
run 'bundle exec rake rails:templates:copy'

# remove files
%w(
  config/initializers/secret_token.rb
  spec/spec_helper.rb
).each do |file|
  remove_file file
end

# secret_token.rb
get @template_url + 'secret_token.rb', 'config/initializers/secret_token.rb'
append_file 'config/initializers/secret_token.rb' do 
<<-TOKEN
#{app_name.split('_').map(&:capitalize).join('')}::Application.config.secret_key_base = secure_token
TOKEN
end

# spec_helper
get @template_url + 'spec_helper.rb', 'spec/spec_helper.rb'

append_file '.rspec' do
<<-RSPEC
--format Fuubar
RSPEC
end

inject_into_file 'config/application.rb', after: 'class Application < Rails::Application' do
<<-RSPEC

    config.generators do |g|
      g.test_framework :rspec,
        routing_specs: false,
        controller_specs: false,
        view_specs: false,
        helper_specs: false
    end
RSPEC
end

append_file '.gitignore' do 
<<-GIT

/vendor/bundler
/coverage
/.secret
/.rbenv-gemsets
.DS_Store
GIT
end

# bootstrap
append_file 'app/assets/stylesheets/application.css' do
<<-CSS
@import "bootstrap";
CSS
end

inject_into_file 'app/assets/javascripts/application.js', before: '//= require_tree .' do
<<-JAVASCRIPT
//= require bootstrap
JAVASCRIPT
end

File.rename('app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.scss')
