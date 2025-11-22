module LineAuthStub
  def stub_line_auth(line_user_id: "U1234567890abcdef")
    # LineLoginApiController#login で生成される state と同じ値をモック
    allow(SecureRandom).to receive(:urlsafe_base64).and_return("dummy_state")

    allow_any_instance_of(LineAuth::AuthorizationService)
      .to receive(:authorization_url)
      .and_return("/line_login_api/callback?code=dummy&state=dummy_state")

    allow_any_instance_of(LineAuth::TokenService)
      .to receive(:exchange_code_for_token)
      .and_return("dummy_id_token")

    allow_any_instance_of(LineAuth::IdTokenVerifier)
      .to receive(:verify_and_get_user_id)
      .with("dummy_id_token")
      .and_return(line_user_id)
  end
end
