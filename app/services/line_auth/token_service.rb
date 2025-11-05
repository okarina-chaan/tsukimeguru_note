module LineAuth
  class TokenService
    TOKEN_URL = "https://api.line.me/oauth2/v2.1/token"

    def exchange_code_for_token(code:, redirect_uri:)
      response = connection.post(TOKEN_URL) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: redirect_uri,
          client_id: ENV["LINE_CHANNEL_ID"],
          client_secret: ENV["LINE_CHANNEL_SECRET"]
        }
      end

      handle_response(response, "id_token")
    end

    private

    def connection
      @connection ||= Faraday.new(url: "https://api.line.me")
    end

    def handle_response(response, key)
      unless response.success?
        raise AuthenticationError, "Token exchange failed: #{response.status}"
      end

      body = JSON.parse(response.body)
      body[key] || raise(AuthenticationError, "#{key} not found in response")
    rescue JSON::ParserError
      raise AuthenticationError, "Invalid JSON response"
    end
  end
end
