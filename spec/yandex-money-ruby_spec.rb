require 'spec_helper'

CLIENT_ID = "12345"
REDIRECT_URI = "http://fixcopy.ru/api/money/result"

describe Yandex::Money::Ruby::Api do
  describe "auth" do
    it 'should properly initialize without client_secret' do
      VCR.use_cassette('init without client secret') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end

    it 'should properly initialize with client_secret' do
      VCR.use_cassette('init with client secret') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account", "123456")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end
  end
end
