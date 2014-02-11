ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara'
require 'capybara/rspec'
require 'factory_girl'

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir.glob("spec/steps/**/*steps.rb") { |f| load f, true }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.before :suite do
    DatabaseRewinder.strategy = :transaction
    DatabaseRewinder.clean_with(:truncation)
  end

  config.before :all do
    FactoryGirl.reload 
  end
  
  config.after :each do
    DatabaseRewinder.start
  end

  config.after :each do
    DatabaseRewinder.clean
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"

  config.include FactoryGirl::Syntax::Methods
end
