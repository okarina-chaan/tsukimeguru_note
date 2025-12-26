require "capybara/rspec"
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

# リモートのSeleniumサーバーを使用する場合の設定
if ENV['SELENIUM_REMOTE']
  Capybara.register_driver :selenium_chrome_headless_remote do |app|
    selenium_url = ENV.fetch('SELENIUM_URL', 'http://selenium_chrome:4444/wd/hub')
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      'goog:chromeOptions' => { 'args' => ['--headless=new', '--no-sandbox', '--disable-dev-shm-usage'] }
    )

    Capybara::Selenium::Driver.new(app,
      browser: :remote,
      url: selenium_url,
      desired_capabilities: caps
    )
  end

  Capybara.javascript_driver = :selenium_chrome_headless_remote
  Capybara.default_driver = :selenium_chrome_headless_remote
end

Capybara.default_max_wait_time = 5
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_driver = :selenium_chrome_headless

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
