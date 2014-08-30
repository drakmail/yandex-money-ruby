require "spec_helper"

CLIENT_ID = "84ED7836D6C0273670C2BA5616AFC9B810F56C10E1F272467E0C158B6232E0E8"
REDIRECT_URI = "http://drakmail.github.io/yandex-money-ruby"
TOKEN = "41001565326286.6837FE2F85C290E0F7ABB0AD7FAD9FC23D0BFF3904254F496626FBB7F9B759B0291CB72C4DB4240004CB859CA69DC809B3BABF9008DFD5B658AC5CD09C5B5B9A50265423464A49D2F20374F9A4DC276ECC134E13C0C3AC60865BD7CAADD952564FC8F97841A6369AFB28FEF0A1531242E2955ECFB7CE3BD531067D1BA734299C"

describe YandexMoney::Api do
  describe "auth" do
    # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
    it "should properly initialize without client_secret" do
      VCR.use_cassette "init without client secret" do
        api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end

    # http://api.yandex.ru/money/doc/dg/reference/obtain-access-token.xml
    it "should get token from code" do
      VCR.use_cassette "get token from authorization code" do
        api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        api.code = "736557BEBF03A1867FFF179F8FADF0F33841471B31BD9ECF2AC59480D0F123475E6261300B1FED6CDB7C067EF4C5E9CC860A31839D52FA5950B5CAFD18C29FE0A31D2F53618D000BAA7C733B2A143C148C4631EFDEAB29151A5EA92B6B099AAEE31A82BF9F7C13EC2E8EAFF44F62D1326EDEBDA4668631ACC367967DDA57F875"
        api.obtain_token
        expect(api.token).to start_with("41001565326286.D206A82773387134BB25CF89A85256EA")
      end
    end
  end

  describe "get account info" do
    # http://api.yandex.ru/money/doc/dg/reference/account-info.xml
    it "should return account info" do
      VCR.use_cassette "get account info" do
        api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history", TOKEN)
        info = api.account_info
        expect(info.account).to eq("41001565326286")
      end
    end
  end
end
