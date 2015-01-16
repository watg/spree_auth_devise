require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
<<<<<<< HEAD

require File.expand_path('../dummy/config/environment', __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'shoulda-matchers'
require 'ffaker'
require 'database_cleaner'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  # config.filter_run focus: true

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
  end

  config.after do
    DatabaseCleaner.clean
    Spree::Ability.abilities.delete(AbilityDecorator) if Spree::Ability.abilities.include?(AbilityDecorator)
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, :type => :controller
  config.include Devise::TestHelpers, :type => :controller
  config.include Rack::Test::Methods, :type => :feature

  Capybara.javascript_driver = :poltergeist
=======

require File.expand_path('../dummy/config/environment', __FILE__)

require 'rspec/rails'
require 'shoulda-matchers'
require 'ffaker'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = false

  config.mock_with :rspec do |mock|
    mock.syntax = [:should, :expect]
  end
>>>>>>> upstream/2-4-stable
end

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }
