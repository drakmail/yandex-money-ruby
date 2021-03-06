require "yandex_money/api/version"
require "httparty"
require "uri"
require "ostruct"

module YandexMoney
  class Api
    include HTTParty

    base_uri "https://sp-money.yandex.ru"
    default_timeout 30

    attr_accessor :client_url, :code, :token, :instance_id

    # Returns url to get token
    def initialize(options)
      # TOKEN provided
      if options.length == 1 && options[:token] != nil
        @token = options[:token]
      else
        @client_id = options[:client_id]
        @redirect_uri = options[:redirect_uri]
        @instance_id = options[:instance_id]
        @client_secret = options[:client_secret]
        if options[:scope] != nil
          if @client_secret
            @client_url = send_authorize_request(
              "client_id" => @client_id,
              "response_type" => "code",
              "redirect_uri" => @redirect_uri,
              "scope" => options[:scope],
              "client_secret" => @client_secret
            )
          else
            @client_url = send_authorize_request(
              "client_id" => @client_id,
              "response_type" => "code",
              "redirect_uri" => @redirect_uri,
              "scope" => options[:scope]
            )
          end
        end
      end
    end

    # obtains and saves token from code
    def obtain_token
      raise "Authorization code not provided" if code == nil
      uri = "/oauth/token"
      if @client_secret
        @token = self.class.post(uri, body: {
          code: @code,
          client_id: @client_id,
          grant_type: "authorization_code",
          redirect_uri: @redirect_url,
          client_secret: @client_secret
        }).parsed_response["access_token"]
      else
        @token = self.class.post(uri, body: {
          code: @code,
          client_id: @client_id,
          grant_type: "authorization_code",
          redirect_uri: @redirect_url
        }).parsed_response["access_token"]
      end
    end

    # obtains account info
    def account_info
      check_token
      uri = "/api/account-info"
      OpenStruct.new self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }).parsed_response
    end

    # obtains operation history
    def operation_history(options=nil)
      check_token
      uri = "/api/operation-history"
      OpenStruct.new self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: options).parsed_response
    end

    # obtains operation details
    def operation_details(operation_id)
      check_token
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

    # basic request payment method
    def request_payment(options)
      check_token
      uri = "/api/request-payment"
      response = OpenStruct.new with_http_retries {
        request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
          "Authorization" => "Bearer #{@token}",
          "Content-Type" => "application/x-www-form-urlencoded"
        }, body: options)

        raise "Insufficient Scope" if request.response.code == "403"
        request.parsed_response
      }
      if response.error
        raise response.error.gsub(/_/, " ").capitalize
      else
        response
      end
    end

    # basic process payment method
    def process_payment(options)
      check_token
      uri = "/api/process-payment"
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: options)

      raise "Insufficient Scope" if request.response.code == "403"
        
      response = OpenStruct.new request.parsed_response

      if response.error
        raise response.error.gsub(/_/, " ").capitalize
      else
        response
      end
    end

    def get_instance_id
      uri = "/api/instance-id"
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: {
        client_id: @client_id
      })

      if request["status"] == "refused"
        raise request["error"].gsub(/_/, " ").capitalize
      else
        request["instance_id"]
      end
    end

    def incoming_transfer_accept(operation_id, protection_code = nil)
      uri = "/api/incoming-transfer-accept"
      if protection_code
        request_body = {
          operation_id: operation_id,
          protection_code: protection_code
        }
      else
        request_body = { operation_id: operation_id }
      end
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: request_body)

      raise "Insufficient Scope" if request.response.code == "403"
      if request["status"] == "refused"
        if request["protection_code_attempts_available"]
          attemps = ", attemps available: #{request["protection_code_attempts_available"]}"
        else
          attemps = ""
        end
        raise "#{request["error"].gsub(/_/, " ").capitalize}#{attemps}"
      else
        true
      end
    end

    def incoming_transfer_reject(operation_id)
      uri = "/api/incoming-transfer-reject"
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: {
        operation_id: operation_id
      })

      raise "Insufficient Scope" if request.response.code == "403"
      if request["status"] == "refused"
        raise "#{request["error"].gsub(/_/, " ").capitalize}"
      else
        true
      end
    end

    def request_external_payment(payment_options)
      payment_options[:instance_id] ||= @instance_id
      uri = "/api/request-external-payment"
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: payment_options)
      raise "Insufficient Scope" if request.response.code == "403"
      if request["status"] == "refused"
        raise "#{request["error"].gsub(/_/, " ").capitalize}"
      else
        OpenStruct.new request.parsed_response
      end
    end

    def process_external_payment(payment_options)
      payment_options[:instance_id] ||= @instance_id
      uri = "/api/process-external-payment"
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: payment_options)
      raise "Insufficient Scope" if request.response.code == "403"
      if request["status"] == "refused"
        raise "#{request["error"].gsub(/_/, " ").capitalize}"
      elsif request["status"] == "in_progress"
        raise "in progress", request["next_retry"]
      else
        OpenStruct.new request.parsed_response
      end
    end

    private

    # Retry when errors
    def with_http_retries(&block)
      begin
        yield
      rescue Errno::ECONNREFUSED, SocketError, Net::ReadTimeout
        sleep 1
        retry
      end
    end

    def check_token
      raise "Token not provided" unless @token
    end

    def send_authorize_request(options)
      uri = "/oauth/authorize"
      self.class.post(uri, body: options).request.path.to_s
    end
  end
end
