Object.send(:remove_const, :Line) if Object.const_defined?(:Line)

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

require 'rspec/rails'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)


Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include ActionDispatch::Integration::Session, type: :request
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
