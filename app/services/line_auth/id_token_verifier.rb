module LineAuth
  class IdTokenVerifier
    VERIFY_URL = "https://api.line.me/oauth2/v2.1/verify"

    def verify_and_get_user_id(id_token)
      raise AuthenticationError, "id_token is blank" if id_token.blank?

      response = connection.post(VERIFY_URL) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(
          id_token: id_token,
          client_id: ENV["LINE_CHANNEL_ID"]
        )
      end

      handle_response(response)
    end

    private

    def connection
      @connection ||= Faraday.new(url: "https://api.line.me")
    end

    def handle_response(response)
      unless response.success?
        raise AuthenticationError, "ID token verification failed: #{response.status}"
      end

      body = JSON.parse(response.body)
      body["sub"] || raise(AuthenticationError, "sub not found in response")
    rescue JSON::ParserError
      raise AuthenticationError, "Invalid JSON response"
    end
  end
end
