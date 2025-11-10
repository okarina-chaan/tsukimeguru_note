require 'rails_helper'

RSpec.describe "アカウント名登録ページへのアクセス制御", type: :system do
  let(:id_token) { "mock_id_token" }
  let(:line_user_id) { "1234567890" }
  let(:user) { create(:user, name: "つきのうさぎ", account_registered: true) }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  it "アカウント名登録済みユーザーはアクセスできない" do
    visit edit_account_name_path
    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content("既にアカウント名が登録されています")
  end
end
