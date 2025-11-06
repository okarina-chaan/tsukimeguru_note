module LineAuth
  class AuthorizationService
    BASE_URL = "https://access.line.me/oauth2/v2.1/authorize"
    SCOPE = "profile openid"

    def initialize(state:, redirect_uri:)
      @state = state
      @redirect_uri = redirect_uri
    end

    def authorization_url
      "#{BASE_URL}?#{query_params}"
    end

    private

    def query_params
      {
        response_type: "code",
        client_id: ENV["LINE_CHANNEL_ID"],
        redirect_uri: @redirect_uri,
        state: @state,
        scope: SCOPE
      }.to_query
    end
  end
end
