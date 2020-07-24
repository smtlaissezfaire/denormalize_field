require 'active_record'
require 'byebug'
require File.dirname(__FILE__) + "/../lib/denormalize_field"
require File.dirname(__FILE__) + "/helpers/models"

RSpec.configure do |config|
  # use old style syntax - new style syntax is terrible!
  config.expect_with(:rspec) { |c| c.syntax = :should }

  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end

  config.around do |example|
    db_config       = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(db_config)

    ActiveRecord::Base.transaction do
      example.run
    end
  end

  config.before(:all) do
  end
end
