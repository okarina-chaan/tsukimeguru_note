require 'rack_session_access/capybara'

module SystemTestHelpers
  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end
end

RSpec.configure do |config|
  config.include SystemTestHelpers, type: :system
end
