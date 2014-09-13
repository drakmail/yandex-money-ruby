require "spec_helper"

describe "Application authorization flow" do
  # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
  it "should properly initialize without client_secret" do
    VCR.use_cassette "init without client secret" do
      api = YandexMoney::Api.new(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "account-info operation-history"
      )
      expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
    end
  end

  # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
  it "should get token with usage of client_secret" do
    VCR.use_cassette "token with client secret" do
      api = YandexMoney::Api.new(
        client_id: "2CB2BBF0788E79A1537437CFD37B15A3E21DAAEE5CD0AE8981118C1CFC6F376A",
        redirect_uri: REDIRECT_URI,
        scope: "account-info operation-history",
        client_secret: "6FAFA896BD2C77E21E240081CDFF3B007451876AB9C186DE2AD2EDDCE29CE3E1BCC1A2789B53583F3398ACD8127A61851357C5D3F444D58F8B5F0AA4F78F088D"
      )
      api.code = "94D93C28E1B27B02A36D495B01BB410EB415EF0152FA30837DEAF307773EDB9734B46954292458D3E5B0E8ABD70C1AF1EE71D64648FB65E7DA8ADAC961970709C3BEBA1AF949F73BAEA2134D386D2ED31CA3F001A45EA05A614432A196A6BEA7B042A0ABDA6E62BA108F864FC400286F388A41454DD961A4A782BF32A80F3816"
      api.obtain_token
      expect(api.token).to start_with("41001565326286")
    end
  end

  # http://api.yandex.ru/money/doc/dg/reference/obtain-access-token.xml
  it "should get token from code" do
    VCR.use_cassette "get token from authorization code" do
      api = YandexMoney::Api.new(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "account-info operation-history"
      )
      api.code = "736557BEBF03A1867FFF179F8FADF0F33841471B31BD9ECF2AC59480D0F123475E6261300B1FED6CDB7C067EF4C5E9CC860A31839D52FA5950B5CAFD18C29FE0A31D2F53618D000BAA7C733B2A143C148C4631EFDEAB29151A5EA92B6B099AAEE31A82BF9F7C13EC2E8EAFF44F62D1326EDEBDA4668631ACC367967DDA57F875"
      api.obtain_token
      expect(api.token).to start_with("41001565326286.D206A82773387134BB25CF89A85256EA")
    end
  end

  it "could be initialized with token" do
    VCR.use_cassette "initialize with token" do
      token_api = YandexMoney::Api.new(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "account-info"
      )
      token_api.code = "7E0C87AE3AFAE96E87FDD780A034FD696264A68CEE8CD9BFDD9F247D32AF6AD1FABC6733D1AFAD65FD08C8112C9D1E8BE80D996F6CF026916154A7A59B431D7A2D02E5845192A2956348C46D85799622DCFEDF4F2DEB80EA81BC1EA5D8874065D0E3828C556754CA60D3B281A1F530DED7B74F415EE8C6B703D34F4A53AE5F90"
      token_api.obtain_token
      api = YandexMoney::Api.new(token: token_api.token)
      expect(api.account_info.account).to eq("41001565326286")
    end
  end
end
