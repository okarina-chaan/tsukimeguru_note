RSpec.shared_examples "require_login" do |path_method, *args|
  it "ログインしていないときはログインページにリダイレクトされる" do
    page.reset_session!

    visit send(path_method, *args)

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("ログインしてください")
  end
end
