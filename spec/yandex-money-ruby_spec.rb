require 'spec_helper'

CLIENT_ID = "12345"
REDIRECT_URI = "http://fixcopy.ru/api/money/result"

describe Yandex::Money::Ruby::Api do
  describe "auth" do
    # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
    it 'should properly initialize without client_secret' do
      VCR.use_cassette('init without client secret') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end

    # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
    it 'should properly initialize with client_secret' do
      VCR.use_cassette('init with client secret') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account", "123456")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end

    # http://api.yandex.ru/money/doc/dg/reference/obtain-access-token.xml
    it 'should get token from code' do
      VCR.use_cassette('get token from authorization code') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        api.code = "ACEB6F56EC46B66F280AFB9C805C61A66A8B5"
        token = api.obtain_token
        expect(token).to start_with("41001565326286.08B91212DB261")
      end
    end
  end
end
