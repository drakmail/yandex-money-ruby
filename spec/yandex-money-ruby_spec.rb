require 'spec_helper'

CLIENT_ID = "703F8432248D8386D24D6B58FB1E9BD99B42EA367E55E98FF4FF1555475CCC51"
REDIRECT_URI = "http://fixcopy.ru/api/money/result"

describe Yandex::Money::Ruby::Api do
  describe "auth" do
    it 'should properly initialize without client_secret' do
      api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
      expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
    end

    it 'should properly initialize with client_secret' do
      api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account", "123456")
      expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
    end
  end
end
