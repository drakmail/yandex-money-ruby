require "yandex_money/api/version"
require "httparty"
require "uri"
require "ostruct"

module YandexMoney
  class Api
    include HTTParty

    base_uri "https://sp-money.yandex.ru"

    attr_accessor :client_url, :code, :token

    # Returns url to get token
    def initialize(client_id, redirect_uri, scope, token = nil)
      @client_id = client_id
      @redirect_uri = redirect_uri
      @token = token
      if @token == nil
        @client_url = send_authorize_request(
          "client_id" => @client_id,
          "response_type" => "code",
          "redirect_uri" => @redirect_uri,
          "scope" => scope
        )
      end
    end

    # obtains and saves token from code
    def obtain_token
      raise "Authorization code not provided" if code == nil
      uri = "/oauth/token"
      @token = self.class.post(uri, body: {
        code: @code,
        client_id: @client_id,
        grant_type: "authorization_code",
        redirect_uri: @redirect_url
      }).parsed_response["access_token"]
    end

    # obtains account info
    def account_info
      uri = "/api/account-info"
      OpenStruct.new self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }).parsed_response
    end

    # obtains operation history
    def operation_history
      uri = "/api/operation-history"
      OpenStruct.new self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }).parsed_response
    end

    # obtains operation details
    def operation_details(operation_id)
      raise "Provide operation_id" if operation_id == nil
      uri = "/api/operation-details"
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: {
        operation_id: operation_id
      })

      raise "Insufficient Scope" if request.response.code == "403"

      details = OpenStruct.new request.parsed_response
      if details.error
        raise details.error.gsub(/_/, " ").capitalize
      else
        details
      end
    end

    private

    def send_authorize_request(options)
      uri = "/oauth/authorize"
      self.class.post(uri, body: options).request.path.to_s
    end
  end
end
