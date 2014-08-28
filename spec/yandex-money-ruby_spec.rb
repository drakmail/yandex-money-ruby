require 'spec_helper'

CLIENT_ID = "84ED7836D6C0273670C2BA5616AFC9B810F56C10E1F272467E0C158B6232E0E8"
REDIRECT_URI = "http://drakmail.github.io/yandex-money-ruby"

describe Yandex::Money::Ruby::Api do
  describe "auth" do
    # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
    it 'should properly initialize without client_secret' do
      VCR.use_cassette('init without client secret') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end

    # http://api.yandex.ru/money/doc/dg/reference/obtain-access-token.xml
    it 'should get token from code' do
      VCR.use_cassette('get token from authorization code') do
        api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        api.code = "736557BEBF03A1867FFF179F8FADF0F33841471B31BD9ECF2AC59480D0F123475E6261300B1FED6CDB7C067EF4C5E9CC860A31839D52FA5950B5CAFD18C29FE0A31D2F53618D000BAA7C733B2A143C148C4631EFDEAB29151A5EA92B6B099AAEE31A82BF9F7C13EC2E8EAFF44F62D1326EDEBDA4668631ACC367967DDA57F875"
        token = api.obtain_token
        expect(token).to start_with("41001565326286.D206A82773387134BB25CF89A85256EA")
      end
    end
  end
end
