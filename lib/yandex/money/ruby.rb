require "yandex/money/ruby/version"
require "httparty"
require "uri"

module Yandex
  module Money
    module Ruby
      class Api
        include HTTParty

        base_uri "https://sp-money.yandex.ru"

        # Returns url to get token
        def initialize(client_id, redirect_uri, scope, client_secret=nil)
          @client_url = send_request(
            "client_id" => client_id,
            "response_type" => "code",
            "redirect_uri" => redirect_uri,
            "scope" => scope
          )
        end

        def client_url
          @client_url
        end

        private
        def auth(code, redirect_uri)
        end

        def send_request(options)
          uri = "/oauth/authorize"
          self.class.post(uri, body: options).request.path.to_s
        end

      end
    end
  end
end
