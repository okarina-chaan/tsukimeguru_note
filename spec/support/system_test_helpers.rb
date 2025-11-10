require 'rack_session_access/capybara'

module SystemTestHelpers
  def sign_in_as(user)
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end
end

RSpec.configure do |config|
  config.include SystemTestHelpers, type: :system
end
