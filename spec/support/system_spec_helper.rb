# spec/support/system_spec_helper.rb
RSpec.configure do |config|
  # system specではWebMockを無効化
  config.before(:each, type: :system) do
    WebMock.disable!
  end

  config.after(:each, type: :system) do
    WebMock.enable!
  end
end
