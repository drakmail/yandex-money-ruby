require "yandex/money/ruby/version"
require "httparty"
require "uri"

module Yandex
  module Money
    module Ruby
      class Api
        include HTTParty

        base_uri "https://sp-money.yandex.ru"
        # authorization code. Needed to obtain token
        attr_accessor :code
        attr_accessor :client_id

        # Returns url to get token
        def initialize(client_id, redirect_uri, scope)
          @client_id = client_id
          @redirect_uri = redirect_uri
          @client_url = send_authorize_request(
            "client_id" => @client_id,
            "response_type" => "code",
            "redirect_uri" => @redirect_uri,
            "scope" => scope
          )
        end

        def client_url
          @client_url
        end

        def obtain_token
          raise 'Authorization code not provided' if code == nil
          uri = "/oauth/token"
          self.class.post(uri, body: {
            code: @code,
            client_id: @client_id,
            grant_type: "authorization_code",
            redirect_uri: @redirect_url
          }).parsed_response["access_token"]
        end

        private
        def send_authorize_request(options)
          uri = "/oauth/authorize"
          self.class.post(uri, body: options).request.path.to_s
        end

      end
    end
  end
end
